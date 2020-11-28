//
//  Comment.swift
//  RedditClient
//
//  Created by Yaroslav on 26.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import Foundation

struct Comment: RedditEntity, Identifiable, Keyable {
    static var kind: String { "t1" }
    var key: CommentID { id }
    
    let id: CommentID
    /// fullname property (a combination of `kind` and `id`, like `t3_ji8ght`)
    let name: Fullname<Comment>
    
    let ups: Int
    // Downvotes. Fuzzed to prevent bit spam
    let downs: Int
    /// User vote
    let likes: Vote
    
    let createdEpoch: TimeInterval
    let createdUTCEpoch: TimeInterval
    
    /// If link is promotional, author is set to `nil`
    let author: String?
    let authorFullname: String
    
    let body: String
}

extension Comment: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        
        case ups
        case downs
        case likes
        
        case createdEpoch = "created"
        case createdUTCEpoch = "created_utc"
        
        case author
        case authorFullname = "author_fullname"
        
        case body
    }
}
