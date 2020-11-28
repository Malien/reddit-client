//
//  Fullname.swift
//  RedditClient
//
//  Created by Yaroslav on 26.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import Foundation

struct Fullname<Entity> where Entity: RedditEntity, Entity: Keyable, Entity.Key: EntityIdentifier {
    let id: Entity.Key
}

extension Fullname: Encodable, Decodable where Entity.Key: Codable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let name = try container.decode(String.self)
        let components = name.components(separatedBy: .init(charactersIn: "_"))
        if components.count != 2  {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Expected fullname proprty to be of kind \(Entity.kind)_<id>, got \(name)")
        }
        let kind = components[0]
        self.id = Entity.Key.init(string: components[1])
        if kind != Entity.kind {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Expected kind to be \(Entity.kind), got \(kind) in \(name)")
        }
    }
    
}

extension Fullname: CustomStringConvertible {
    var description: String { "\(Entity.kind)_\(id)" }
}
