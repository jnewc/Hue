//
//  File.swift
//  
//
//  Created by Jack Newcombe on 02/02/2020.
//

import Foundation

// MARK: Linking

/// Describes an error response for a link attempt.
public struct LinkErrorResponse: Decodable {
    
    /// Describes the content of an error response.
    public struct ErrorContent: Decodable {
        /// An error code indicating the type of the error.
        public let type: Int
        /// A textual description of the error.
        public let description: String
    }
    
    /// Error details.
    public let error: ErrorContent
    
    /// Indicates whether the error type implied that the Link button should be pressed.
    public var isLinkRequest: Bool {
        return error.type == 101
    }
}

/// Describes a success response for a link attempt.
public struct LinkSuccessResponse: Decodable {
    
    /// Describes the content of a success response.
    public struct SuccessContent: Decodable {
        /// The username of a newly linked user.
        public let username: String
    }
    
    /// Describes the success state of the link
    public let success: SuccessContent
}

extension Array where Element == LinkErrorResponse {
    var isLinkRequest: Bool {
        return count == 1 && self.first?.isLinkRequest ?? false
    }
}

// MARK: Lights

/// Describes all light elements for a bridge.
public struct Lights: DynamicDecodable {
    /// Describes a light and its configuration.
    public struct Light: Decodable {
        enum CodingKeys: String, CodingKey {
            case state
            case capabilities
            case name
            case modelID = "modelid"
            case manufacturerName = "manufacturername"
            case productName = "productname"
        }
        
        /// Describes the configuration state of a `Light`.
        public struct State: Decodable {
            enum CodingKeys: String, CodingKey {
                case isOn = "on"
                case isReachable = "reachable"
                case brightness = "bri"
            }
            /// Indicates if a light can be reached by the bridge.
            public let isReachable: Bool
            /// On/Off state of the light. On=true, Off=false
            public let isOn: Bool
            /// Brightness of the light. This is a scale from the minimum brightness the light is capable of, 1, to the maximum capable brightness, 254.
            public let brightness: Int
        }
        
        /// Describes the capabilities of a `Light`
        public struct Capabilities: Decodable {
            enum CodingKeys: String, CodingKey {
                case isCertified = "certified"
                case control
            }
            public struct Control: Decodable {
                enum CodingKeys: String, CodingKey {
                    case minDimLevel = "mindimlevel"
                    case maxLumen = "maxlumen"
                }
                //
                public let minDimLevel: Int?
                public let maxLumen: Int?
            }
            public let isCertified: Bool
            public let control: Control
        }

        /// Details the state of the light, see the `State` struct for more details.
        public let state: State
        /// The capabilities of the light.
        public let capabilities: Capabilities
        /// A unique, editable name given to the light.
        public let name: String
        /// The hardware model of the light.
        public let modelID: String
        /// The manufacturer name.
        public let manufacturerName: String
        /// The product name.
        public let productName: String
    }

    /// Lights items, keyed by ID
    public var results: [String : Lights.Light]

    init(results: [String: Lights.Light]) {
        self.results = results
    }
}

// MARK: Groups

/// Describes all group elements for a bridge.
public struct Groups: DynamicDecodable {

    public struct Group: Decodable {
        /// Describes the configuration state of a `Group`
        public struct State: Decodable {
            enum CodingKeys: String, CodingKey {
                case isAllOn = "all_on"
                case isAnyOn = "any_on"
            }
            /// “all_on” indicates all lights within the group are ON (true) or OFF (false).
            public let isAllOn: Bool
            /// “any_on” is true when one or more lights within the group is ON.
            public let isAnyOn: Bool
        }
        
        /// Describes the action state of a `Group`
        public struct Action: Decodable {
            enum CodingKeys: String, CodingKey {
                case isOn = "on"
                case brightness = "bri"
            }
            public let isOn: Bool
            public let brightness: Int
        }
        
        /// A unique, editable name given to the group.
        public let name: String
        /// If not provided upon creation “LightGroup” is used. Can be “LightGroup”, “Room” or either “Luminaire” or “LightSource” if a Multisource Luminaire is present in the system.
        public let type: String
        /// The IDs of the lights that are in the group.
        public let lights: [String]
        /// The ordered set of sensor ids from the sensors which are in the group. The array can be empty.
        public let sensors: [String]
        /// Contains a state representation of the group
        public let state: State
        /// The light state of one of the lamps in the group.
        public let action: Action
    }
    
    /// Groups, keyed by ID
    public var results: [String : Groups.Group]

    init(results: [String: Groups.Group]) {
        self.results = results
    }
}

// MARK: Config


/// Describes all configuration elements for a bridge. Note all times are stored in UTC.
public struct Config: Decodable {
    enum CodingKeys: String, CodingKey {
        case name
        case zigbeeChannel = "zigbeechannel"
        case bridgeID = "bridgeid"
        case isDHCP = "dhcp"
        case ipAddress = "ipaddress"
        case modelID = "modelid"
        case apiVersion = "apiversion"
        case whitelist = "whitelist"
    }
    
    /// Describes whitelisted user IDs.
    public struct Whitelist: DynamicDecodable {
        /// Describesa whitelist item.
        public struct WhitelistItem: Decodable {
            enum CodingKeys: String, CodingKey {
                case lastUseDate = "last use date"
                case createDate = "create date"
                case name
            }
            /// The datetime of the last request made by this device.
            public let lastUseDate: String
            /// The datetime of creation
            public let createDate: String
            /// The name of the whitelisted  user or device.
            public let name: String
        }

        /// Whitelist items, keyed by UUID
        public var results: [String: WhitelistItem]

        init(results: [String: WhitelistItem]) {
            self.results = results
        }
    }
    
    /// Name of the bridge. This is also its uPnP name, so will reflect the actual uPnP name after any conflicts have been resolved.
    public let name: String
    /// The current wireless frequency channel used by the bridge. It can take values of 11, 15, 20,25 or 0 if undefined (factory new).
    public let zigbeeChannel: String
    /// The unique bridge id. This is currently generated from the bridge Ethernet mac address.
    public let bridgeID: String
    /// Whether the IP address of the bridge is obtained with DHCP.
    public let isDHCP: Bool
    /// IP address of the bridge.
    public let ipAddress: String
    /// This parameter uniquely identifies the hardware model of the bridge (BSB001, BSB002).
    public let modelID: String
    /// The version of the hue API in the format <major>.<minor>.<patch>, for example 1.2.1
    public let apiVersion: String
    /// A list of whitelisted user IDs.
    public let whitelist: Whitelist
    
}

// MARK: Schedules

/// Describe all schedule elements for a bridge.
public struct Schedules: DynamicDecodable {
    /// Describes a schedule and it's configuration
    public struct Schedule: Decodable {
        enum CodingKeys: String, CodingKey {
            case name
            case description
            case time
            case created
            case status
            case command
            case recycle
            case localTime = "localtime"
        }
        
        /// Describes the command to execute when the scheduled event occurs.
        public struct Command: Decodable {
            /// A command configuration specific to the source schedule
            public struct Body: Decodable {
                enum CodingKeys: String, CodingKey {
                    case scene
                    case transitionTime = "transitiontime"
                    case brightnessIncrement = "bri_inc"
                }
                /// If present, describes the scene targeted by this command.
                public let scene: String?
                /// If present, describes the amount of time this command should take to execute.
                public let transitionTime: Double?
                /// If present, describes the amount by which the brightness shoudl increment during execution.
                public let brightnessIncrement: Double?
            }
            /// Path to a light resource, a group resource or any other bridge resource (including “/api/<username>/”)
            public let address: String
            /// The HTTPS method used to send the body to the given address. Either “POST”, “PUT”, “DELETE” for local addresses.
            public let method: String
            /// The command configuration.
            public let body: Body
        }
        
        
        /// Name for the new schedule. If a name is not specified then the default name, “schedule”, is used.
        /// If the name is already taken a space and number will be appended by the bridge, e.g. “schedule 1”.
        public let name: String
        /// Description of the new schedule. If the description is not specified it will be empty.
        public let description: String
        /// Time when the scheduled event will occur. Time is measured in the bridge in UTC time. Either time or localtime has to be provided.
        /// DEPRECATED: This attribute will be removed in the future. Please use localtime instead.
        /// + The following time patterns are allowed:
        /// + Absolute time
        /// + Randomized time
        /// + Recurring times
        /// + Recurring randomized times
        /// + Timers
        public let time: String
        public let created: String
        /// Application is only allowed to set “enabled” or “disabled”.
        /// Disabled causes a timer to reset when activated (i.e. stop & reset). “enabled” when not provided on creation.
        public let status: String
        /// Command to execute when the scheduled event occurs. If the command is not valid then an error of type 7 will be raised.
        public let command: Command
        /// When true: Resource is automatically deleted when not referenced anymore in any resource link.
        /// Only on creation of resource. “false” when omitted.
        public let recycle: Bool
        /// Local time when the scheduled event will occur.Either time or localtime has to be provided.
        /// A schedule configured with localtime will operate on localtime and is returned along with the time attribute (UTC) for backwards compatibility.
        public let localTime: String
    }
    
    
    /// Schedule items, keyed by ID
    public var results: [String: Schedule]

    init(results: [String: Schedule]) {
        self.results = results
    }
}

// MARK: Scenes

/// Describe all scene elements for a bridge.
public struct Scenes: DynamicDecodable {
    public struct Scene: Decodable {
        /// Human readable name of the scene. Is set to <id> if omitted on creation.
        public let name: String
        /// If not provided on creation a “LightScene” is created. Supported types:
        /// + 'LightScene': Default. Represents a scene which links to a specific group. While creating a new GroupScene, the group attribute shall be provided.
        ///   The lights array is a read-only attribute, it cannot be modified, and shall not be provided upon GroupScene creation.
        /// + 'GroupScene': When lights in a group is changed, the GroupScenes associated to this group will be automatically updated with the new list of lights in the group.
        ///   The new lights added to the group will be assigned with default states for associated GroupScenes.
        public let type: String
        /// group ID that a scene is linked to.
        public let group: String?
        /// The light ids which are in the scene. This array can be empty.
        public let lights: [String]
        /// Whitelist user that created or modified the content of the scene. Note that changing name does not change the owner.
        public let owner: String
        /// Indicates whether the scene can be automatically deleted by the bridge.
        /// Only available by `POST` Set to ‘false’ when omitted.
        /// Legacy scenes created by `PUT` are defaulted to true.
        /// When set to ‘false’ the bridge keeps the scene until deleted by an application.
        public let recycle: Bool
        /// Indicates that the scene is locked by a rule or a schedule and cannot be deleted until all resources requiring or that reference the scene are deleted.
        public let locked: Bool
        /// Only available on a GET of an individual scene resource (/api/<username>/scenes/<id>).
        /// Not available for scenes created via a PUT. Reserved for future use.
        public let picture: String
    }
    
    /// Scene items, keyed by ID
    public var results: [String: Scene]

    init(results: [String: Scene]) {
        self.results = results
    }
}

// MARK: Sensors


/// Describes all sensor elements for a bridge.
public struct Sensors: DynamicDecodable {
    /// Describes a sensor and its configuration.
    public struct Sensor: Decodable {
        /// Describes the state of a sensor.
        public struct State: Decodable {
            /// The on/off state of the sensor.
            public let flag: Bool
        }
        /// Describes the configuration state of the sensor.
        public struct Config: Decodable {
            enum CodingKeys: String, CodingKey {
                case isOn = "on"
                case isConfigured = "configured"
                case isReachable = "reachable"
            }
            /// Indicates whether or not the sensor has been configured.
            public let isConfigured: Bool?
            /// Indicates whether or not the sensor is currently reachable.
            public let isReachable: Bool?
            /// Indicates whether or not the sensor is currently activated.
            public let isOn: Bool
        }
    }
    
    /// Sensor items, keyed by ID.
    public var results: [String: Sensor]

    init(results: [String: Sensor]) {
        self.results = results
    }
}

// MARK: LightState

/// Describes the modified state of a `Light`
public struct LightState: Decodable {
}

/// Describes the modified state of a `Group`
public struct GroupState: Decodable {
}

// MARK: Dynamic Decodable Helpers

protocol DynamicDecodable: Decodable {
    associatedtype InnerDecodable: Decodable
    
    var results: [String: InnerDecodable] { get set }

    init(results: [String: InnerDecodable])
}

extension DynamicDecodable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CustomCodingKeys.self)

        var results = [String: InnerDecodable]()
        for key in container.allKeys {
            let value = try container.decode(InnerDecodable.self, forKey: CustomCodingKeys(stringValue: key.stringValue)!)
            results[key.stringValue] = value
        }
        self = .init(results: results)
    }
}

struct CustomCodingKeys: CodingKey {
    var stringValue: String
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    var intValue: Int?
    init?(intValue: Int) {
        return nil
    }
}
