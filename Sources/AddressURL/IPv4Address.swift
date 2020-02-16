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
    
    var url: URL {
        return URL(address: self)
    }
}
