//
//  PostBookmarksViewModel.swift
//  RedditClient
//
//  Created by Yaroslav on 09.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import Foundation

class PostBookmarksViewModel {
    
    let subscription: SubscriptionID<SavedPosts>
    
    init(onBookmarked: @escaping (PostID, Bool) -> Void) {
        subscription = ApplicationServices.store.saved.subscribe { event in
            switch event {
            case .added(let post):
                onBookmarked(post.id, true)
            case .removed(let post):
                onBookmarked(post.id, false)
            }
        }
    }
    
    deinit {
        ApplicationServices.store.saved.unsubscribe(subscription)
    }
    
    func bookmark(post: Post) {
        ApplicationServices.store.saved.add(post: post)
    }
    
    func remove(bookmarkedPost post: Post) {
        ApplicationServices.store.saved.remove(postWithID: post.id)
    }
    
    func toggle(bookmarkOfPost post: Post) {
        ApplicationServices.store.saved.toggle(bookmarkOfPost: post)
    }
    
    func isBookmarked(postWithID id: PostID) -> Bool {
        ApplicationServices.store.saved.contains(postWithID: id)
    }
}
