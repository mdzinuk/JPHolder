//
//  Protocol.swift
//  JPHolder
//
//  Created by Mohammad Arafat Hossain on 9/03/21.
//

import Foundation

/**
 Itemable: Adopted by Models so that, we can use for generic/shared component
 */

protocol Itemable: Identifiable {
    var counter: Int { get }
    var title: String { get }
    var description: String { get }
}

extension Post: Itemable {
    var counter: Int {
        return id
    }
    
    var description: String {
        return body
    }
}

extension Post.Comment: Itemable {
    var title: String {
        return "\(name)(\(email))"
    }
    
    var counter: Int {
        return id
    }
    
    var description: String {
        return body
    }
}
