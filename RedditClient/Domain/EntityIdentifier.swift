//
//  EntityIdentifier.swift
//  RedditClient
//
//  Created by Yaroslav on 11.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import Foundation

protocol EntityIdentifier {
    associatedtype Entity
    init(string: String)
}

extension EntityIdentifier where Entity: RedditEntity, Entity: Identifiable, Entity.ID == Self {
    var fullname: Fullname<Entity> { Fullname(id: self) }
}
