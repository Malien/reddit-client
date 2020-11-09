//
//  Subreddit.swift
//  RedditClient
//
//  Created by Yaroslav on 09.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import Foundation

struct Subreddit : Hashable {
    let name: String
}

extension Subreddit: CustomStringConvertible {
    var description: String { name }
}

extension Subreddit: ExpressibleByStringLiteral {
    typealias StringLiteralType = String
    init(stringLiteral value: StringLiteralType) {
        name = value
    }
}

extension Subreddit: Codable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(name)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.name = try container.decode(String.self)
    }
}

extension Subreddit : Comparable {
    static func < (lhs: Subreddit, rhs: Subreddit) -> Bool {
        lhs.name < rhs.name
    }
    
    static func <= (lhs: Subreddit, rhs: Subreddit) -> Bool {
        lhs.name <= rhs.name
    }
    
    static func > (lhs: Subreddit, rhs: Subreddit) -> Bool {
        lhs.name > rhs.name
    }
    
    static func >= (lhs: Subreddit, rhs: Subreddit) -> Bool {
        lhs.name >= rhs.name
    }
}

extension Subreddit : Identifiable {
    var id: String { name }
}
