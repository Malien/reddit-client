//
//  SubscriptionID.swift
//  RedditClient
//
//  Created by Yaroslav on 10.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import Foundation

struct SubscriptionID<Entity>: Hashable {
    private let id: Int
    var next: SubscriptionID { SubscriptionID(id: id + 1) }
    static var firstID: SubscriptionID { SubscriptionID(id: 0) }
}
