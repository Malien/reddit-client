//
//  SinglePostViewModel.swift
//  RedditClient
//
//  Created by Yaroslav on 02.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import Foundation

class SinglePostViewModel {
    
    var subscription: SubscriptionHolder
    
    init(subreddit: String, onPost: @escaping (Post) -> Void) {
        subscription = reddit.topPosts(from: subreddit, limit: 1) { result in
            switch result {
            case .success(let posts):
                if let post = posts.first {
                    onPost(post)
                } else {
                    print("No posts")
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    deinit {
        subscription.unsubscribe()
    }
    
}
