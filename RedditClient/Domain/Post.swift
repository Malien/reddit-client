//
//  Post.swift
//  RedditClient
//
//  Created by Yaroslav on 28.10.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import Foundation

/// This is a post, but throughout reddit api doccumentations
/// it is refered to as a link for some reason
/// This is both, serialization container for reddit API responses, and domain model object
struct Post: RedditEntity, Identifiable, Keyable {
    static var kind: String { "t3" }
    var key: PostID { id }
    
    let id: PostID
    /// fullname property (a combination of `kind` and `id`, like `t3_ji8ght`)
    let name: String
    
    // Upvotes. Fuzzed to prevent bot spam
    let ups: Int
    // Downvotes. Fuzzed to prevent bit spam
    let downs: Int
    /// User vote
    let likes: Vote
    
    let createdEpoch: TimeInterval
    let createdUTCEpoch: TimeInterval
    
    /// If link is promotional, author is set to `nil`
    let author: String?
    let clicked: Bool
    let domain: String
    let hidden: Bool
    let isSelf: Bool
    let locked: Bool
    let numComents: Int
    let over18: Bool
    let permalink: URL
    let saved: Bool
    /// Always accurate, despite ups and downs being fuzzed
    let score: Int
    let selfText: String
    let selfTextHTML: String?
    let subreddit: String
    let subredditID: String
    let thumbnail: Thumbnail
    let title: String
    let url: URL
    let stickied: Bool
    let archived: Bool
    let pinned: Bool
    
    let preview: PostPreview?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        
        case ups
        case downs
        case likes
        
        case createdEpoch = "created"
        case createdUTCEpoch = "created_utc"
        
        case author
        case clicked
        case domain
        case hidden
        case isSelf = "is_self"
        case locked
        case numComents = "num_comments"
        case over18 = "over_18"
        case permalink
        case saved
        case score
        case selfText = "selftext"
        case selfTextHTML = "selftext_html"
        case subreddit
        case subredditID = "subreddit_id"
        case thumbnail
        case title
        case url
        case stickied
        case archived
        case pinned
        case preview
        
    }
}
