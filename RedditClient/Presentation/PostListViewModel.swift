//
//  PostListViewModel.swift
//  RedditClient
//
//  Created by Yaroslav on 09.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import Foundation

class PostListViewModel {
    
    private var subscription: Cancellable

    init(subreddit: Subreddit, onPosts: @escaping (PaginationContainer<Post>) -> Void) {
        subscription = ApplicationServices.shared.reddit.topPosts(from: subreddit, limit: 5, force: true) { result in
            switch result {
            case .success(let posts):
                onPosts(posts)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    deinit {
        subscription.cancel()
    }
    
}
