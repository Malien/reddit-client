//
//  RedditEntity.swift
//  RedditClient
//
//  Created by Yaroslav on 28.10.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import Foundation

/// Reddit types out their entities like such
/// ```ts
/// {
///     "kind": "listing" | "t1" | "t2" | "t3" | "t4" | "t5" | "t6"
///     "data": // actual entity fields
/// }
/// ```
/// This is done solely for type-checking purposes
protocol RedditEntity where Self: Codable {
    static var kind: String { get }
}

extension RedditEntity where Self: Keyable {
    var fullname: String { "\(Self.kind)_\(key)" }
}
