//
//  PaginationContainer.swift
//  RedditClient
//
//  Created by Yaroslav on 08.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import Foundation

protocol Keyable {
    associatedtype Key
    var key: Key { get }
}

struct PaginationContainer<T> where T: Keyable {
    var items: [T]
    let start: T.Key?
    let totalCount: Int
    
    var moreAvailable: Bool { items.count != totalCount }
    
    var doFetch: Optional<(_ limit: Int, _ after: T.Key?) -> Void> = nil
    
    func fetchMore(count: Int) {
        if let doFetch = doFetch {
            doFetch(count, items.first?.key)
        }
    }
}

extension PaginationContainer: Codable where T: Codable, T.Key: Codable {
    enum CodingKeys: String, CodingKey {
        case items
        case start
        case totalCount
    }
}
