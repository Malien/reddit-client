//
//  PostTableViewCell.swift
//  RedditClient
//
//  Created by Yaroslav on 08.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import UIKit

final class PostTableViewCell: UITableViewCell {
    
    private let postView = PostView(post: nil).autolayouted()
    
    public var onComment: Optional<() -> Void> {
        set { postView.onComment = newValue }
        get { postView.onComment }
    }
    public var onVote: Optional<() -> Void> {
        set { postView.onVote = newValue }
        get { postView.onVote }
    }
    public var onShare: Optional<() -> Void> {
        set { postView.onShare = newValue }
        get { postView.onShare }
    }
    public var onBookmark: Optional<() -> Void> {
        set { postView.onBookmark = newValue }
        get { postView.onBookmark }
    }
    public var onDoubleTap: Optional<() -> Void> {
        set { postView.onDoubleTap = newValue }
        get { postView.onDoubleTap }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .background
        
        contentView.addSubview(postView)

        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: postView   , attribute: .leading , relatedBy: .equal, toItem: contentView, attribute: .leading , multiplier: 1, constant: 0),
            NSLayoutConstraint(item: postView   , attribute: .top     , relatedBy: .equal, toItem: contentView, attribute: .top     , multiplier: 1, constant: 0),
            NSLayoutConstraint(item: postView   , attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: contentView, attribute: .bottom  , relatedBy: .equal, toItem: postView   , attribute: .bottom  , multiplier: 1, constant: 40)
        ])
    }
    
    override func prepareForReuse() {
        postView.populate(post: nil)
        postView.onBookmark = nil
        postView.onComment = nil
        postView.onVote = nil
        postView.onShare = nil
    }
    
    func populate(post: Post) {
        postView.populate(post: post)
    }
    
    func populate(bookmarked: Bool) {
        postView.populate(bookmarked: bookmarked)
    }
    
    required init?(coder: NSCoder) { nil }

}
