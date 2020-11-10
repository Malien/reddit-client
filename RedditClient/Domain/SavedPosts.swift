//
//  SavedPosts.swift
//  RedditClient
//
//  Created by Yaroslav on 09.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import Foundation

struct SavedPosts {
    private(set) var posts: [Post] = []
    private var ids: Set<PostID> = []
    
    enum Event {
        case added(Post)
        case removed(Post)
    }
    
    typealias EE = EventEmitter<Event, Self>
    var eventEmitter: EE = EventEmitter(queue: ApplicationServices.dataQueue)
    
    private mutating func add(nonexistantPost post: Post) {
        posts.append(post)
        ids.insert(post.id)
        eventEmitter.emit(event: .added(post))
    }
    
    private mutating func remove(existingPostWithID id: PostID) {
        ids.remove(id)
        let idx = posts.firstIndex { $0.id == id }
        if let idx = idx {
            let removed = posts.remove(at: idx)
            eventEmitter.emit(event: .removed(removed))
        }
    }

    mutating func add(post: Post) {
        if !ids.contains(post.id) {
            add(nonexistantPost: post)
        }
    }
    
    mutating func remove(postWithID id: PostID) {
        if ids.contains(id) {
            remove(existingPostWithID: id)
        }
    }
    
    mutating func toggle(bookmarkOfPost post: Post) {
        if ids.contains(post.id) {
            remove(existingPostWithID: post.id)
        } else {
            add(nonexistantPost: post)
        }
    }
    
    func contains(postWithID id: PostID) -> Bool {
        ids.contains(id)
    }
    
    mutating func subscribe(_ listener: @escaping EE.Listener) -> EE.SubID {
        eventEmitter.subscribe(listener)
    }
    
    mutating func unsubscribe(_ subscription: EE.SubID) {
        eventEmitter.unsubscribe(subscription)
    }
}

extension SavedPosts: Codable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(posts)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.posts = try container.decode([Post].self)
        self.ids = Set(posts.map { $0.id })
    }
}
