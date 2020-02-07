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
    public func lights() -> AnyPublisher<Lights, Hue.Error> {
        execute(with: .lights, type: Lights.self)
    }
    
    /// Publishes all available groups for the hub
    public func groups() -> AnyPublisher<Groups, Hue.Error> {
        execute(with: .groups, type: Groups.self)
    }
    
    /// Publishes the full config for the hub
    public func config() -> AnyPublisher<Config, Hue.Error> {
        execute(with: .config, type: Config.self)
    }
    
    /// Publishes all available schedules for the hub
    public func schedules() -> AnyPublisher<Schedules, Hue.Error> {
        execute(with: .schedules, type: Schedules.self)
    }
    
    /// Publishes all available scenes for the hub
    public func scenes() -> AnyPublisher<Scenes, Hue.Error> {
        execute(with: .scenes, type: Scenes.self)
    }
        
    /// Publishes all available sensors for the hub
    public func sensors() -> AnyPublisher<Sensors, Hue.Error> {
        execute(with: .sensors, type: Sensors.self)
    }
    
    // MARK: Elements
    
    /// Publishes the `Light` with the given ID
    /// - Parameter id: The ID of the `Light` to publish
    public func light(id: String) -> AnyPublisher<Lights.Light, Hue.Error> {
        execute(with: .light(id: id), type: Lights.Light.self)
    }
    
    /// Sets the state of a light and publishes the result
    /// - Parameters:
    ///   - id: The ID of the light
    ///   - state: The new state of the light
    public func light(id: String, state: Bool) -> AnyPublisher<[LightState], Hue.Error> {
        execute(with: .lightOn(id: id), type: [LightState].self, body: .on(state: state))
    }
    
    /// Publishes the `Group` with the given ID
    /// - Parameter id: The ID of the `Group` to publish
    public func group(id: String) -> AnyPublisher<Groups.Group, Hue.Error> {
        execute(with: .group(id: id), type: Groups.Group.self)
    }
    
    /// Sets the state of a group and publishes the result
    /// - Parameters:
    ///   - id: The ID of the group
    ///   - state: The new state of the group
    public func group(id: String, state: Bool) -> AnyPublisher<[GroupState], Hue.Error> {
        execute(with: .groupOn(id: id), type: [GroupState].self)
    }
    
    /// Publishes the `Schedule` with the given ID
    /// - Parameter id: The ID of the `Schedule` to publish
    public func schedule(id: String) -> AnyPublisher<Schedules.Schedule, Hue.Error> {
        execute(with: .schedule(id: id), type: Schedules.Schedule.self)
    }
    
    /// Publishes the `Scene` with the given ID
    /// - Parameter id: The ID of the `Scene` to publish
    public func scene(id: String) -> AnyPublisher<Scenes.Scene, Hue.Error> {
        execute(with: .scene(id: id), type: Scenes.Scene.self)
    }
    
    /// Publishes the `Sensor` with the given ID
    /// - Parameter id: The ID of the `Sensor` to publish
    public func sensor(id: String) -> AnyPublisher<Sensors.Sensor, Hue.Error> {
        execute(with: .sensor(id: id), type: Sensors.Sensor.self)
    }
    
    // MARK: Helpers
    
    private func execute<T>(with endpoint: Endpoint, type: T.Type, body: RequestBody? = nil) -> AnyPublisher<T, Hue.Error> where T: Decodable {
        execute(endpoint: endpoint, method: body == nil ? .get : .put, body: body)
            .decode(type: type, decoder: JSONDecoder())
            .print()
            .autoMapDecodingError()
            .autoMapErrorType(Hue.Error.self, default: .unknown)
            .eraseToAnyPublisher()
    }

}
