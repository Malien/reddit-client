//
//  PostBookmarksViewModel.swift
//  RedditClient
//
//  Created by Yaroslav on 09.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import Foundation

class PostBookmarksViewModel {
    
    private let bookmarksSub: SubscriptionID<SavedPosts>
    private var refreshSubs: [Cancellable] = []
    
    init(onBookmarked: @escaping (PostID, Bool) -> Void, onUpdate: Optional<(Post) -> Void> = nil) {
        bookmarksSub = ApplicationServices.shared.store.saved.subscribe {
            let (post, event) = $0
            switch event {
            case .added:
                onBookmarked(post.id, true)
            case .removed:
                onBookmarked(post.id, false)
            case .updated:
                guard let onUpdate = onUpdate else { return }
                onUpdate(post)
            }
        }
    }
    
    deinit {
        ApplicationServices.shared.store.saved.unsubscribe(bookmarksSub)
        refreshSubs.cancel()
    }
    
    func bookmark(post: Post) {
        ApplicationServices.shared.store.saved.add(post: post)
    }
    
    func remove(bookmarkedPost post: Post) {
        ApplicationServices.shared.store.saved.remove(postWithID: post.id)
    }
    
    func toggle(bookmarkOfPost post: Post) {
        ApplicationServices.shared.store.saved.toggle(bookmarkOfPost: post)
    }
    
    func isBookmarked(postWithID id: PostID) -> Bool {
        ApplicationServices.shared.store.saved.contains(postWithID: id)
    }
    
    func refreshBookmarks() {
        let sub = ApplicationServices.shared.reddit.service.fetchPosts(withIDs: posts.map { $0.id }) {
            print($0)
        }
        refreshSubs.append(sub)
    }
    
    var posts: [Post] { ApplicationServices.shared.store.saved.posts }
}
