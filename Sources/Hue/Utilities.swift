//
//  File.swift
//  
//
//  Created by Jack Newcombe on 02/02/2020.
//

import Foundation
import Combine

@available(iOS 13.0, macOS 10.15, *)
extension Publisher {
    
    func autoMapErrorType<T>(_ errorType: T.Type, default: T) -> Publishers.MapError<Self, T> where T: Error {
        return self.mapError {
            switch $0 {
            case let error as T:
                return error
            default:
                return `default`
            }
        }
    }
    
    func autoMapDecodingError() -> Publishers.MapError<Self, Error> {
        return self.mapError { error -> Swift.Error in
            switch error {
            case is DecodingError:
                return Hue.Error.parsingFailure(errorMessage: error.localizedDescription)
            default:
                return error
            }
        }
    }
    
}
