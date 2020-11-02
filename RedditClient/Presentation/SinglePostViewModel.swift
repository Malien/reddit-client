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
    var bookmarked: Bool = false {
        didSet {
            bookmarkHandler(bookmarked)
        }
    }
    private let bookmarkHandler: (Bool) -> Void
    
    init(subreddit: String, onPost: @escaping (Post) -> Void, onBookmark: @escaping (Bool) -> Void) {
        bookmarkHandler = onBookmark
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
