//
//  File.swift
//
//
//  Created by Zachary Gorak on 2/15/20.
//

import Foundation
import Network

extension IPv4Address {
    public init?(url: URL) {
        guard let host = url.hostname else {
            return nil
        }
        self.init(host)
    }
    
    public var url: URL {
        return URL(address: self)
    }
}

public struct IPv4AddressWithPort {
	public let ipV4Address: IPv4Address
	public let port: Int?
	
	public init(ipV4Address: IPv4Address, port: Int? = nil) {
		self.ipV4Address = ipV4Address
		self.port = port
	}
	
	public init?(ipV4AddressString: String, port: Int? = nil) {
		guard let ipV4Address = IPv4Address(ipV4AddressString) else { return nil }
		self.ipV4Address = ipV4Address
		self.port = port
	}
}
