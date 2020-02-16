import XCTest
import Network
import Foundation
@testable import AddressURL

final class AddressURLTests: XCTestCase {
    func testEightDotEightDotEightDotEight() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let url = URL(staticString: "8.8.8.8")
        
        XCTAssertEqual(url.hostname, "8.8.8.8")
        XCTAssertNotNil(url)
        XCTAssertNotNil(url.ipv4Address)
        XCTAssertNil(url.ipv6Address)
        XCTAssertFalse(url.isEmail)
    }

    func testValidIPv6() {
        var url = URL(staticString: "2001:4860:4860::8888")

        XCTAssertEqual(url.hostname, "2001:4860:4860::8888")
        XCTAssertNotNil(url)
        XCTAssertNil(url.ipv4Address)
        XCTAssertNotNil(url.ipv6Address)
        XCTAssertFalse(url.isEmail)
        
        var c = URLComponents()
        c.host = "64:ff9b::0.0.0.0"
        XCTAssert(c.url != nil, "\(c) should not be nil")
        XCTAssert(c.url?.host != nil, "\(c).host should not be nil")

        let validHosts = [
            "[64:ff9b::0.0.0.0]",
            "[::]",
            "[::1]",
            "[::ffff:0.0.0.0]",
            "[::ffff:0:0.0.0.0]",
            "[100::]",
            "[2001::]",
            "[2001:20::]",
            "[2001:db8::]",
            "[2002::]"
        ]
        for v in validHosts {
            url = URLComponent.host(v).url!
            XCTAssertNil(url.ipv4Address)
            XCTAssertFalse(url.isIPv4)
            XCTAssertTrue(url.isIPv6)
            XCTAssertNotNil(url.ipv6Address)
            XCTAssertFalse(url.isEmail)
            XCTAssertEqual(url.with(scheme: "https")?.absoluteString, "https://\(v)")
        }

        let validIps = [
            "64:ff9b::0.0.0.0",
            "::",
            "::1",
            "::ffff:0.0.0.0",
            "::ffff:0:0.0.0.0",
            "100::",
            "2001::",
            "2001:20::",
            "2001:db8::",
            "2002::"
        ]
        for v in validIps {
            let ip = IPv6Address(v)
            XCTAssertNotNil(ip)
            url = URL(address: ip!)
            XCTAssertNotNil(url)
            XCTAssertNil(url.ipv4Address)
            XCTAssertNotNil(url.ipv6Address)
            XCTAssertFalse(url.isEmail)
            
            XCTAssertNotNil(URLComponent.host(v).url)
            XCTAssertTrue(URLComponent.host(v).url!.isIPv6)
            XCTAssertNotNil(URLComponent.host(v).url!.ipv6Address)
            XCTAssertFalse(URLComponent.host(v).url!.isEmail)
            XCTAssertFalse(URLComponent.host(v).url!.isIPv4)
        }
    }
    
    func testInvalidIPv6() {
        let url = URL(staticString: "4860:4860:8888.9")

        XCTAssertNil(url.ipv4Address)
        XCTAssertNil(url.ipv6Address)
        XCTAssertFalse(url.isEmail)
    }
    
    func testEmail() {
        var url = URL(email: "mailto:hello@gorak.us")
        XCTAssertNotNil(url?.emailAddress)
        XCTAssertEqual(url?.emailAddress, "hello@gorak.us")
        url = URL(email: "hello@gorak.us")
        XCTAssertNotNil(url?.emailAddress)
        XCTAssertEqual(url?.emailAddress, "hello@gorak.us")
        url = URL(email: "mailto://hello@gorak.us")
        XCTAssertNotNil(url?.emailAddress)
        XCTAssertEqual(url?.emailAddress, "hello@gorak.us")
        url = URL(email: "mailto:hello+tag@gorak.us")
        XCTAssertNotNil(url?.emailAddress)
        XCTAssertEqual(url?.emailAddress, "hello+tag@gorak.us")
    }

    static var allTests = [
        ("test8.8.8.8", testEightDotEightDotEightDotEight),
        ("test2001:4860:4860::8888", testValidIPv6),
        ("testInvalid", testInvalidIPv6),
        ("testEmail", testEmail)
    ]
}
