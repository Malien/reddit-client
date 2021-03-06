//
//  Comment.swift
//  RedditClient
//
//  Created by Yaroslav on 26.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import Foundation

struct Comment: RedditEntity, Identifiable, Timestamped {
    static var kind: String { "t1" }

    struct ID: Hashable {
        let id: String
    }

    let id: ID
    /// fullname property (a combination of `kind` and `id`, like `t1_ji8ght`)
    let name: Fullname<Comment>
    
    // Upvotes. Fuzzed to prevent bot spam
    let ups: Int
    // Downvotes. Fuzzed to prevent bot spam
    let downs: Int
    /// Always accurate, despite ups and downs being fuzzed
    let score: Int
    /// User vote
    let likes: Vote

    let createdEpoch: TimeInterval
    let createdEpochUTC: TimeInterval
    
    /// If link is promotional, author is set to `nil`
    let author: String?
    let authorFullname: String
    
    let permalink: String
    let body: String
    
    var url: URL {
        ApplicationServices.APIBaseURL.appendingPathComponent(permalink)
    }
}

extension Comment.ID: Encodable, Decodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(id)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.id = try container.decode(String.self)
    }
    
}

extension Comment.ID: CustomStringConvertible {
    var description: String { id }
}

extension Comment.ID: EntityIdentifier {
    typealias Entity = Comment
    init(string: String) { self.id = string }
}

extension Comment: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        
        case ups
        case downs
        case likes
        case score
        
        case createdEpoch = "created"
        case createdEpochUTC = "created_utc"
        
        case author
        case authorFullname = "author_fullname"
        
        case permalink
        case body
    }
}
