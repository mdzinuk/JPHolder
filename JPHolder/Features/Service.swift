//
//  Service.swift
//  JPHolder
//
//  Created by Mohammad Arafat Hossain on 9/03/21.
//

import Foundation
import Combine

/**
 Service: A reference type, assuming, will reuse again and again within VM label. Currently, retrieving Posts and Comments are putting here together with static methds, although they are using from different places.
 */

class Service {
    static func getAvailablePosts() -> AnyPublisher<[Post], NetworkManager.Error> {
        NetworkManager
            .executeTask(path: "posts")
            .eraseToAnyPublisher()
    }
    
    static func getCommentsFor(_ postid: Int) -> AnyPublisher<[Post.Comment], NetworkManager.Error> {
        NetworkManager
            .executeTask(path: "comments", ["postId": String(postid)])
            .eraseToAnyPublisher()
    }
}
