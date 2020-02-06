//
//  Hue+API.swift
//  
//
//  Created by Jack Newcombe on 02/02/2020.
//

import Foundation
import Combine


@available(iOS 13.0, macOS 10.15, *)
extension Hue {
    
    // MARK: Collections
    
    /// Publishes all available lights for the hub
    public func lights() throws -> AnyPublisher<Lights, Hue.Error> {
        try execute(with: .lights, type: Lights.self)
    }
    
    /// Publishes all available groups for the hub
    public func groups() throws -> AnyPublisher<Groups, Hue.Error> {
        try execute(with: .groups, type: Groups.self)
    }
    
    /// Publishes the full config for the hub
    public func config() throws -> AnyPublisher<Config, Hue.Error> {
        try execute(with: .config, type: Config.self)
    }
    
    /// Publishes all available schedules for the hub
    public func schedules() throws -> AnyPublisher<Schedules, Hue.Error> {
        try execute(with: .schedules, type: Schedules.self)
    }
    
    /// Publishes all available scenes for the hub
    public func scenes() throws -> AnyPublisher<Scenes, Hue.Error> {
        try execute(with: .scenes, type: Scenes.self)
    }
        
    /// Publishes all available sensors for the hub
    public func sensors() throws -> AnyPublisher<Sensors, Hue.Error> {
        try execute(with: .sensors, type: Sensors.self)
    }
    
    // MARK: Elements
    
    /// Publishes the `Light` with the given ID
    /// - Parameter id: The ID of the `Light` to publish
    public func light(id: String) throws -> AnyPublisher<Lights.Light, Hue.Error> {
        try execute(with: .light(id: id), type: Lights.Light.self)
    }
    
    /// Sets the state of a light and publishes the result
    /// - Parameters:
    ///   - id: The ID of the light
    ///   - state: The new state of the light
    public func light(id: String, state: Bool) throws -> AnyPublisher<[LightState], Hue.Error> {
        try execute(with: .lightOn(id: id), type: [LightState].self, body: .on(state: state))
    }
    
    /// Publishes the `Group` with the given ID
    /// - Parameter id: The ID of the `Group` to publish
    public func group(id: String) throws -> AnyPublisher<Groups.Group, Hue.Error> {
        try execute(with: .group(id: id), type: Groups.Group.self)
    }
    
    /// Sets the state of a group and publishes the result
    /// - Parameters:
    ///   - id: The ID of the group
    ///   - state: The new state of the group
    public func group(id: String, state: Bool) throws -> AnyPublisher<[GroupState], Hue.Error> {
        try execute(with: .groupOn(id: id), type: [GroupState].self)
    }
    
    /// Publishes the `Schedule` with the given ID
    /// - Parameter id: The ID of the `Schedule` to publish
    public func schedule(id: String) throws -> AnyPublisher<Schedules.Schedule, Hue.Error> {
        try execute(with: .schedule(id: id), type: Schedules.Schedule.self)
    }
    
    /// Publishes the `Scene` with the given ID
    /// - Parameter id: The ID of the `Scene` to publish
    public func scene(id: String) throws -> AnyPublisher<Scenes.Scene, Hue.Error> {
        try execute(with: .scene(id: id), type: Scenes.Scene.self)
    }
    
    /// Publishes the `Sensor` with the given ID
    /// - Parameter id: The ID of the `Sensor` to publish
    public func sensor(id: String) throws -> AnyPublisher<Sensors.Sensor, Hue.Error> {
        try execute(with: .sensor(id: id), type: Sensors.Sensor.self)
    }
    
    // MARK: Helpers
    
    private func execute<T>(with endpoint: Endpoint, type: T.Type, body: RequestBody? = nil) throws -> AnyPublisher<T, Hue.Error> where T: Decodable {
        try execute(endpoint: endpoint, method: body == nil ? .get : .put, body: body)
        .decode(type: type, decoder: JSONDecoder())
        .print()
        .autoMapDecodingError()
        .autoMapErrorType(Hue.Error.self, default: .unknown)
        .eraseToAnyPublisher()
    }

}
