//
//  CommentsViewModel.swift
//  RedditClient
//
//  Created by Yaroslav on 28.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import Foundation
import Combine

class CommentsViewModel: ObservableObject {
    @Published
    private var _comments: PaginationContainer<Comment> = PaginationContainer(items: [], start: nil, hasMore: false)
    
    var sub: Cancellable!
    let batchSize: Int
    
    init(for postID: PostID, batchSize: Int) {
        self.batchSize = batchSize
        sub = ApplicationServices.shared.reddit.comments(for: postID, limit: batchSize, force: true) { result in
            switch result {
            case .success(let comments):
                DispatchQueue.main.async {
                    self._comments = comments
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func fetchMore() {
        if _comments.hasMore {
           _comments.fetchMore(count: batchSize)
        }
    }
    
    var comments: [Comment] {
        _comments.items
    }
    
    deinit {
        sub.cancel()
    }
}
