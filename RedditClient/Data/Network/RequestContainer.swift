//
//  RequestContainer.swift
//  RedditClient
//
//  Created by Yaroslav on 28.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import Foundation

protocol RequestContainer {
    associatedtype Data: Keyable;
    var start: Data.Key? { get }
}

struct TopPostsRequest: RequestContainer, Hashable, Codable {
    typealias Data = Post
    let subreddit: Subreddit
    let start: PostID?
}

struct CommentsRequest: RequestContainer, Hashable, Codable {
    typealias Data = Comment
    let post: PostID
    let start: CommentID?
}

