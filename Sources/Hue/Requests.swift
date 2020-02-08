//
//  File.swift
//  
//
//  Created by Jack Newcombe on 04/02/2020.
//

import Foundation

struct RequestBody {
    let data: Data
}

extension RequestBody {
    static func from<T>(_ encodable: T) -> Self? where T: Encodable {
        guard let data = try? JSONEncoder().encode(encodable) else { return nil }
        return RequestBody(data: data)
    }
}

extension RequestBody {
    static func link(deviceType: String) -> Self? {
        return .from(["devicetype": deviceType])
    }
    
    static func on(state: Bool) -> Self? {
        let dict = ["on": state]
        return .from(dict)
    }
}
