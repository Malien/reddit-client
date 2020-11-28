//
//  CodableTuple.swift
//  RedditClient
//
//  Created by Yaroslav on 26.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import Foundation

struct CodableTuple<T, U> {
    var first: T
    var second: U
}

extension CodableTuple: Codable where T: Codable, U: Codable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(first)
        try container.encode(second)
    }
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        first = try container.decode(T.self)
        second = try container.decode(U.self)
    }
}
