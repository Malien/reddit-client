//
//  Vote.swift
//  RedditClient
//
//  Created by Yaroslav on 28.10.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import Foundation

/// Voting value is represented as either `true` (upvoted), `false` (downvoted) or `null` (no vote)
/// This is an adapter to make those values a bit more "swifty"
enum Vote {
    case up
    case down
    case none
}

extension Vote: Codable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .up: try container.encode(true)
        case .down: try container.encode(false)
        case .none: try container.encodeNil()
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .none
        } else if try container.decode(Bool.self) {
            self = .up
        } else {
            self = .down
        }
    }
}

