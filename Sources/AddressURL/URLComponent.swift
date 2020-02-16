//
//  File.swift
//  
//
//  Created by Zachary Gorak on 2/15/20.
//

import Foundation

public enum URLComponent {
    case host(_: String?)
    case scheme(_: String?)
    case user(_: String?)
    case password(_: String?)
    case path(_: String)
    
    public var url: URL? {
        var comps = URLComponents()
        switch self {
        case .host(let host):
            comps.host = host
        case .scheme(let scheme):
            comps.scheme = scheme
        case .user(let user):
            comps.user = user
        case .password(let password):
            comps.password = password
        case .path(let path):
            comps.path = path
        }

        return comps.url
    }
}
