//
//  PaginationContainer.swift
//  RedditClient
//
//  Created by Yaroslav on 08.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import Foundation

struct PaginationContainer<T> where T: Identifiable {
    var items: [T]
    let start: T.ID?

    var hasMore: Bool
    
    var invoked = false
    var doFetch: Optional<(_ limit: Int, _ after: T.ID?) -> Void> = nil
    
    mutating func fetchMore(count: Int) {
        if let doFetch = doFetch, !invoked {
            invoked = true
            doFetch(count, items.last?.id)
        }
    }
}

extension PaginationContainer: Codable where T: Codable, T.ID: Codable {
    enum CodingKeys: String, CodingKey {
        case items
        case start
        case hasMore
    }
}
