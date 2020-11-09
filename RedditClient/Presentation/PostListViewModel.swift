//
//  PostListViewModel.swift
//  RedditClient
//
//  Created by Yaroslav on 09.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import Foundation

class PostListViewModel {
    
    private var subscription: SubscriptionHolder
    private let postsHandler: (PaginationContainer<Post>) -> Void
    
    init(subreddit: Subreddit, onPosts: @escaping (PaginationContainer<Post>) -> Void) {
        postsHandler = onPosts
        subscription = reddit.topPosts(from: subreddit, limit: 5) { result in
            switch result {
            case .success(let posts):
                onPosts(posts)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    deinit {
        subscription.unsubscribe()
    }
    
}
