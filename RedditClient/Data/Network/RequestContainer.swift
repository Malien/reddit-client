//
//  RequestContainer.swift
//  RedditClient
//
//  Created by Yaroslav on 28.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import Foundation

protocol RequestContainer {
    associatedtype Data: Identifiable;
    var start: Data.ID? { get }
}

struct TopPostsRequest: RequestContainer, Hashable, Codable {
    typealias Data = Post
    let subreddit: Subreddit
    let start: Post.ID?
}

struct CommentsRequest: RequestContainer, Hashable, Codable {
    typealias Data = Comment
    let post: Post.ID
    let start: Comment.ID?
}

