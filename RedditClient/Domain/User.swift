//
//  User.swift
//  RedditClient
//
//  Created by Yaroslav on 26.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import Foundation

struct User: RedditEntity, Keyable {
    static var kind: String { "t5" }
    
    let id: UserID
}
