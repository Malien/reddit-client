//
//  SinglePostViewModel.swift
//  RedditClient
//
//  Created by Yaroslav on 02.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import Foundation

final class SinglePostViewModel {
    
    var subscription: Cancellable
    var bookmarked: Bool = false {
        didSet {
            bookmarkHandler(bookmarked)
        }
    }
    private let bookmarkHandler: (Bool) -> Void
    
    init(subreddit: Subreddit, onPost: @escaping (Post) -> Void, onBookmark: @escaping (Bool) -> Void) {
        bookmarkHandler = onBookmark
        subscription = ApplicationServices.shared.reddit.topPosts(from: subreddit, limit: 1, force: true) { result in
            switch result {
            case .success(let posts):
                if let post = posts.items.first {
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
        subscription.cancel()
    }
    
}
