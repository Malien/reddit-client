//
//  PostBookmarksViewModel.swift
//  RedditClient
//
//  Created by Yaroslav on 09.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import Foundation

final class PostBookmarksViewModel {
    
    private let bookmarksSub: SubscriptionID<SavedPosts>
    private var refreshSubs: [Cancellable] = []
    private let handleSearch: Optional<() -> Void>
    private var _filter: String? = nil
    var filter: String? {
        get { _filter }
        set {
            if let filter = newValue {
                filteredPosts = posts.filter {
                    $0.title.localizedCaseInsensitiveContains(filter) ||
                    $0.selfText.localizedCaseInsensitiveContains(filter) ||
                    $0.author?.localizedCaseInsensitiveContains(filter) ?? false ||
                    $0.subreddit.name.localizedCaseInsensitiveContains(filter)
                }
                print("filteredPosts: \(filteredPosts)")
            }
            if let handleSearch = handleSearch, _filter != newValue {
                _filter = newValue
                handleSearch()
            } else {
                _filter = newValue
            }
        }
    }
    private var filteredPosts: [Post] = []
    
    init(onBookmarked: @escaping (PostID, Bool) -> Void, onUpdate: Optional<(Post) -> Void> = nil, onSearch: Optional<() -> Void> = nil) {
        self.handleSearch = onSearch
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
    
    var posts: [Post] { filter == nil ? ApplicationServices.shared.store.saved.posts : filteredPosts }

}
