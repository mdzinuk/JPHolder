//
//  Models.swift
//  JPHolder
//
//  Created by Mohammad Arafat Hossain on 9/03/21.
//

import Foundation

/**
 Post: Model with Identifiable(SwifUI list required) is the business level data presentation
 Comment: Model with Identifiable(SwifUI list required) is the business level data presentation, keeping inside Post as without Post Comments are valueless(assuming in context of app flow).
 */

struct Post: Codable, Identifiable {
    let userId, id: Int
    let title: String
    let body: String
    
    struct Comment: Codable, Identifiable {
        let postId, id: Int
        let name: String
        let email: String
        let body: String
    }
}

/**
 JPHError: Type, declares error with description
 */
public enum  JPHError: Error, CustomStringConvertible {
    case decodeError, encodeError, missingOutput, unknown(Swift.Error)
    
    public var description: String {
        switch self {
        case .missingOutput:
            return "Output is missing, please check the url!"
        case .decodeError, .encodeError:
            return "Model, encoding/decoding failed!"
        default:
            return "Unknow error, please rebuild the app!"
        }
    }
}
