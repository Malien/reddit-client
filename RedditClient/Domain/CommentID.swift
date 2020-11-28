//
//  CommentID.swift
//  RedditClient
//
//  Created by Yaroslav on 26.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import Foundation

/// Type to differenciate in code between PostID, CommentID etc.
struct CommentID: Hashable, EntityIdentifier {
    typealias Entity = Comment
    let id: String
    init(string: String) { self.id = string }
}

extension CommentID: Encodable, Decodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(id)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.id = try container.decode(String.self)
    }
    
}

extension CommentID: CustomStringConvertible {
    var description: String { id }
}
