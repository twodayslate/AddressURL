import Foundation
import Network
import EmailValidator

extension URL {
    // MARK: - Initializers
    /**
    - SeeAlso:
    [Swift by Sundell](https://www.swiftbysundell.com/articles/constructing-urls-in-swift/)
     */
    public init(staticString string: StaticString) {
        guard let url = URL(string: "\(string)") else {
            preconditionFailure("Invalid static URL string: \(string)")
        }
        self = url
    }

    public init(address: IPv4Address) {
        self = URLComponent.host("\(address)").url!
    }
    
    public init(address: IPv6Address) {
        self = URLComponent.host("[\(address)]").url!
    }
    
    /**
        Creates a URL with the `mailto://` scheme
     */
    public init?(email: String, allowTopLevelDomains: Bool = true, allowInternational: Bool = true) {
        if email.hasPrefix("mailto://") {
            let address = String(email.suffix(email.count - "mailto://".count))
            guard EmailValidator.validate(email: address, allowTopLevelDomains: allowTopLevelDomains, allowInternational: allowInternational) else {
                return nil
            }
            self.init(string: "mailto://\(address)")
            return
        } else if email.hasPrefix("mailto:") {
            let address = String(email.suffix(email.count - "mailto:".count))
            guard EmailValidator.validate(email: address, allowTopLevelDomains: allowTopLevelDomains, allowInternational: allowInternational) else {
                return nil
            }
            self.init(string: "mailto://\(address)")
            return
        }
        
        guard EmailValidator.validate(email: email, allowTopLevelDomains: allowTopLevelDomains, allowInternational: allowInternational) else {
            return nil
        }
        self.init(string: "mailto://\(email)")
    }

    // TODO: I want url.component(.host) to return the URLComponent.host

    public func with(component: URLComponent, resolvingAgainstBaseURL: Bool = false) -> URL? {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: resolvingAgainstBaseURL) else {
            return nil
        }
        switch component {
        case .host(let host):
            components.host = host
        case .scheme(let scheme):
            components.scheme = scheme
        case .user(let user):
            components.user = user
        case .password(let password):
            components.password = password
        case .path(let path):
            components.path = path
        }
        return components.url
    }

    // MARK: - Email
    
    /**
        A very rudimentary email validator. Use [EmailValidator](https://github.com/evanrobertson/EmailValidator) for a more robust validator/
     */
    public var isEmail: Bool {
        guard let _ = self.emailAddress else {
            return false
        }
        return true
    }

    public var emailAddress: String? {
        var email: String?
        if self.scheme == "mailto" {
            email = String(self.absoluteString.suffix(self.absoluteString.count - "mailto://".count))
            
        } else if let noScheme = self.with(component: .scheme(nil)) {
            email = String(noScheme.absoluteString.suffix(noScheme.absoluteString.count - "//".count))
        }
        
        guard let address = email else {
            return nil
        }
        if EmailValidator.validate(email: address, allowTopLevelDomains: true, allowInternational: true) {
            return address
        }
        return nil
    }

    // MARK: - Helpers
    
    /**
    - SeeAlso:
     [TLDExtractSwift](https://github.com/gumob/TLDExtractSwift/blob/master/Source/TLDExtract.swift#L59)
     */
    public var hostname: String? {
        if let host = self.host {
            return host
        }
        guard let toParse = self.absoluteString.removingPercentEncoding else {
            return nil
        }
        let schemePattern: String = "^(\\p{L}+:)?//"
        let hostPattern: String = "([0-9\\p{L}][0-9\\p{L}-]{1,61}\\.?)?   ([\\p{L}-]*  [0-9\\p{L}]+)  (?!.*:$).*$".replacingOccurrences(of: " ", with: "", options: .regularExpression)
        if let regex: NSRegularExpression = try? NSRegularExpression(pattern: "^\(schemePattern)"), regex.matches(in: toParse, range: NSRange(location: 0, length: toParse.count)).count > 0 {
            let components: [String] = toParse.replacingOccurrences(of: schemePattern, with: "", options: .regularExpression).components(separatedBy: "/")
            guard let component: String = components.first, !component.isEmpty else { return nil }
            return component
        } else if let regex: NSRegularExpression = try? NSRegularExpression(pattern: "^\(hostPattern)"), regex.matches(in: toParse, range: NSRange(location: 0, length: toParse.count)).count > 0 {
            let components: [String] = toParse.replacingOccurrences(of: schemePattern, with: "", options: .regularExpression).components(separatedBy: "/")
            guard let component: String = components.first, !component.isEmpty else { return nil }
            return component
        }

        return nil
    }

    internal func dump_components() -> [String:Any?] {
        let dict: [String:Any?] = [
            "scheme": self.scheme,
            "user": self.user,
            "password": self.password,
            "host": self.host,
            "port": self.port,
            "path": self.path,
            "pathExtension": self.pathExtension,
            "pathComponents": self.pathComponents,
            "query": self.query,
            "baseUrl": self.baseURL,
            "fragment": self.fragment,
        ]
        return dict
    }

    /**
        When a URL recieves a string with out a valid schema it may still create the url, this will attempt to fix that
        as just settings the URLComponent.schema doesn't always give the desired output
     */
    public func with(scheme newScheme: String) -> URL? {
        var using = self
        if self.scheme != nil {
            using = self.with(component: .scheme(nil))!
        }
        var absStr = using.absoluteString
        if using.absoluteString.hasPrefix("//") {
            absStr = String(using.absoluteString.suffix(using.absoluteString.count - "//".count))
        }
        if newScheme.hasSuffix("://") {
            return URL(string: newScheme + absStr)
        } else if newScheme.hasSuffix(":") {
            return URL(string: newScheme + "//" + absStr)
        } else {
            return URL(string: newScheme + "://" + absStr)
        }
    }

    // MARK: - IPv4
    public var ipv4Address: IPv4Address? {
        guard let host = self.hostname else {
            return nil
        }
        return IPv4Address(host)
    }
    
    public var isIPv4: Bool {
        return self.ipv4Address != nil ? true : false
    }
    
    // MARK: - IPv6
    public var ipv6Address: IPv6Address? {
        guard let host = self.hostname else {
            return nil
        }
        return IPv6Address(host)
    }
    
    public var isIPv6: Bool {
        return self.ipv6Address != nil ? true : false
    }
}
