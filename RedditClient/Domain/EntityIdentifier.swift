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
}

extension EntityIdentifier where Entity: RedditEntity {
    var fullname: String { "\(Entity.kind)_\(self)" }
}
