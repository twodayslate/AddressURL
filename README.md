# AddressURL

A simple Swift Package that extends URL with some helpful functions for IP and email address

Requires iOS 12.0+ as the [Network](https://developer.apple.com/documentation/network) API is used.

For tld and domain information check out https://github.com/gumob/TLDExtractSwift

For improved email validation use https://github.com/evanrobertson/EmailValidator

## Usage

IP Address can be converted to URLs

```swift
IPv4Address("8.8.8.8").url!.with(component: .scheme("https")!.absoluteString // https://8.8.8.8
IPv6Address("::").url!.with(component: .scheme("https")!.absoluteString // https://[::]
```

Alternativly you can get an IP Address from a URL

```swift
let url = URL(string: "https://8.8.8.8")
url.ipv4Address // 8.8.8.8

let url2 = URL(string: "https://[::]")
url.ipv6Address // ::
```

Specific URLComponents can be changed

```swift
let url = URL(string: "https://zac.gorak.us")
url.with(component: .scheme("ftp") // ftp://zac.gorak.us
```

Email addresses

```swift
let url = URL(email: "hello@gorak.us")
url.absoluteString // mailto://hello@gorak.us
url.emailAddress // hello@gorak.us
```
