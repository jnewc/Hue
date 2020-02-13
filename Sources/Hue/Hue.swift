//
//  Hue.swift
//  Automa
//
//  Created by Jack Newcombe on 04/01/2020.
//  Copyright © 2020 Jack Newcombe. All rights reserved.
//

import Foundation
import Combine

@available(iOS 13.0, macOS 10.15, *)

/// Describes a Phillips Hue bridge and provides various method for accessing its devices, groups, schedules, scenes, and other data.
public class Hue {
    
    enum HTTPMethod: String {
        case get
        case post
        case put
    }
    
    /// Describes a Hue domain error
    public enum Error: Swift.Error {
        case unknown
        case unsupportedVersion
        case urlParseFailure
        case networkError
        case httpError(statusCode: Int)
        case parsingFailure(errorMessage: String)
        
        var localizedDescription: String {
            switch self {
            case .unknown:
                return "Unknown error"
            case .unsupportedVersion:
                return "SDK version of iOS 13.0 or above required"
            case .urlParseFailure:
                return "Failed to parse endpoint URL"
            case .networkError:
                return "Network request error"
            case .httpError(let statusCode):
                return "HTTP Error: \(statusCode)"
            case .parsingFailure:
                return "Failed to parse API response"
            }
        }
    }
    
    /// Describes a response given while attempting to whitelist a new username.
    public enum ConnectResponse {
        /// Indicates that a link is required (i.e. the link button should be pressed on the hub)
        case linkRequired
        /// Indicates that a link was successful. `username` contains the whitelisted user ID.
        case linked(username: String)
    }
    
    /// The host URL of the bridge, including scheme.
    public let bridgeURL: String
    
    /// The whitelisted username, if present.
    public var username: String?
    
    /// Create an instance of the
    /// - Parameters:
    ///   - bridgeURL: The host URL of the bridge, including scheme, e.g. https://10.1.2.3/
    ///   - username: Optional username. If not specified, use `connect()` to generate a new one
    public init(bridgeURL: String, username: String? = nil) {
        self.bridgeURL = bridgeURL
        self.username = username
    }
    
    func url(forEndpoint endpoint: Endpoint) -> URL? {
        guard let username = username else {
            return URL(string: "\(bridgeURL)/api/\(endpoint.path)")
        }
        return URL(string: "\(bridgeURL)/api/\(username)/\(endpoint.path)")
    }
    
    /// Requests a new whitelisted user ID from the bridge.
    /// - Parameter deviceType: A name for the device making the link. e.g. the name of your app.
    public func link(deviceType: String) -> AnyPublisher<Hue.ConnectResponse, Hue.Error> {
        return execute(endpoint: .login, method: .post, body: .link(deviceType: deviceType))
            .tryMap { data throws in
                let decoder = JSONDecoder()
                if let response = try? decoder.decode([LinkErrorResponse].self, from: data), response.isLinkRequest {
                    return .linkRequired
                }
                do {
                    let response = try decoder.decode([LinkSuccessResponse].self, from: data)
                    guard let username = response.first?.success.username else { throw Error.unknown }
                    self.username = username
                    return .linked(username: username)
                } catch let error as DecodingError {
                    throw Error.parsingFailure(errorMessage: error.localizedDescription)
                } catch let error {
                    throw error
                }
            }
            .autoMapErrorType(Hue.Error.self, default: .unknown)
            .eraseToAnyPublisher()
    }
    
    func execute(endpoint: Endpoint, method: HTTPMethod = .get, body: RequestBody? = nil) -> AnyPublisher<Data, Hue.Error> {
        guard let url = url(forEndpoint: endpoint) else {
            return Fail(outputType: Data.self, failure: Error.urlParseFailure).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.httpBody = body?.data
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap {
                let (data, response) = $0
                guard let httpResponse = response as? HTTPURLResponse else { throw Error.networkError }
                guard httpResponse.statusCode == 200 else { throw Error.httpError(statusCode: httpResponse.statusCode) }
                #if DEBUG
                print("[Hue HTTP Response]: \n\n \(String(data: data, encoding: .utf8)!)")
                #endif
                return data
            }
            .autoMapErrorType(Hue.Error.self, default: .unknown)
            .eraseToAnyPublisher()
    }
    
}

struct Endpoint {
    let path: String
}

extension Endpoint {
    
    // MARK: Collection Endpoints
    
    static var lights: Self {
        Endpoint(path: "lights")
    }
    
    static var groups: Self {
        Endpoint(path:"groups")
    }
    
    static var config: Self {
        Endpoint(path:"config")
    }
    
    static var schedules: Self {
        Endpoint(path:"schedules")
    }
    
    static var scenes: Self {
        Endpoint(path:"scenes")
    }
    
    static var sensors: Self {
        Endpoint(path:"sensors")
    }
    
    static var rules: Self {
        Endpoint(path:"rules")
    }
    
    // MARK: Element Endpoints
    
    static func light(id: String) -> Self {
        Endpoint(path: "lights/\(id)")
    }

    static func lightOn(id: String) -> Self {
        Endpoint(path: "lights/\(id)/state")
    }
    
    static func group(id: String) -> Self {
        Endpoint(path: "groups/\(id)")
    }
    
    static func groupOn(id: String) -> Self {
        Endpoint(path: "groups/\(id)/action")
    }
    
    static func schedule(id: String) -> Self {
        Endpoint(path: "schedules/\(id)")
    }

    static func scene(id: String) -> Self {
        Endpoint(path: "scenes/\(id)")
    }
    
    static func sensor(id: String) -> Self {
        Endpoint(path: "sensor/\(id)")
    }

    // MARK: Login
    
    static var login: Self {
        Endpoint(path: "")
    }
}
