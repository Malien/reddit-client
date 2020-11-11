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
    
    enum EventType {
        case added
        case updated
        case removed
    }
    
    typealias Event = (post: Post, type: EventType)
    typealias EE = EventEmitter<Event, Self>
    var eventEmitter: EE = EventEmitter(queue: ApplicationServices.dataQueue)
    
    private mutating func add(nonexistantPost post: Post) {
        posts.append(post)
        ids.insert(post.id)
        eventEmitter.emit(event: (post, .added))
    }
    
    private mutating func remove(existingPostWithID id: PostID) {
        ids.remove(id)
        let idx = posts.firstIndex { $0.id == id }
        if let idx = idx {
            let post = posts.remove(at: idx)
            eventEmitter.emit(event: (post, .removed))
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
    
    mutating func update(postWithID id: PostID, to post: Post) {
        if ids.contains(id) {
            if let idx = posts.firstIndex(where: { $0.id == id }) {
                posts[idx] = post
                eventEmitter.emit(event: (post, .updated))
            }
        }
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

extension SavedPosts: EventSource { }
