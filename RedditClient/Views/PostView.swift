//
//  PostView.swift
//  RedditClient
//
//  Created by Yaroslav on 28.10.2020.
//  Copytrailing © 2020 Yaroslav. All rights reserved.
//

import UIKit
import SDWebImage

final class PostView : UIView {
    
    private let header: PostHeaderView
    // TODO: Come up with declarative way of handling appearing and disappearing views
    private let thumbnail: PostThumbnailView
    private let selftext = UILabel().autolayouted()
    private let bookmarkButton: BookmarkButton
    private let interactionsView: PostInteractionsView

    init(post: Post?, bookmarked: Bool = false, onBookmark: @escaping () -> Void = { }) {
        header = PostHeaderView(post: post).autolayouted()
        thumbnail = PostThumbnailView(imageFromSource: post?.preview?.images.first?.source).autolayouted()
        bookmarkButton = BookmarkButton(bookmarked: bookmarked, onClick: onBookmark).autolayouted()
        interactionsView = PostInteractionsView(votes: post?.score ?? 0, comments: post?.commentCount ?? 0).autolayouted()
        super.init(frame: CGRect.zero)

        populate(post: post)
        populate(bookmarked: bookmarked)
        
        selftext.numberOfLines = 0
        selftext.textColor = .text
        selftext.font = .defaultText
        
        directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        
        addSubview(selftext)
        addSubview(header)
        addSubview(thumbnail)
        addSubview(bookmarkButton)
        addSubview(interactionsView)

        NSLayoutConstraint.activate([
            // Header in view
            NSLayoutConstraint(item: header, attribute: .leading , relatedBy: .equal, toItem: self , attribute: .leadingMargin , multiplier: 1, constant: 0),
            NSLayoutConstraint(item: header, attribute: .top     , relatedBy: .equal, toItem: self , attribute: .topMargin     , multiplier: 1, constant: 0),
            NSLayoutConstraint(item: header, attribute: .trailing, relatedBy: .equal, toItem: self , attribute: .trailingMargin, multiplier: 1, constant: 0),
            // Thumbnail in view
            NSLayoutConstraint(item: thumbnail, attribute: .top     , relatedBy: .equal, toItem: header, attribute: .bottom  , multiplier: 1, constant: 0),
            NSLayoutConstraint(item: thumbnail, attribute: .leading , relatedBy: .equal, toItem: self  , attribute: .leading , multiplier: 1, constant: 0),
            NSLayoutConstraint(item: thumbnail, attribute: .trailing, relatedBy: .equal, toItem: self  , attribute: .trailing, multiplier: 1, constant: 0),
//            thumbnailHeightConstraint,
            // Selftext in view
            NSLayoutConstraint(item: selftext, attribute: .top     , relatedBy: .equal, toItem: thumbnail, attribute: .bottom        , multiplier: 1, constant: 16),
            NSLayoutConstraint(item: selftext, attribute: .leading , relatedBy: .equal, toItem: self     , attribute: .leadingMargin , multiplier: 1, constant: 0),
            NSLayoutConstraint(item: selftext, attribute: .trailing, relatedBy: .equal, toItem: self     , attribute: .trailingMargin, multiplier: 1, constant: 0),
            // Bookmark button in view
            NSLayoutConstraint(item: bookmarkButton, attribute: .top     , relatedBy: .equal, toItem: selftext, attribute: .bottom        , multiplier: 1, constant: 8),
            NSLayoutConstraint(item: bookmarkButton, attribute: .leading , relatedBy: .equal, toItem: self    , attribute: .leadingMargin , multiplier: 1, constant: 0),
            NSLayoutConstraint(item: bookmarkButton, attribute: .trailing, relatedBy: .equal, toItem: self    , attribute: .trailingMargin, multiplier: 1, constant: 0),
            // Interactions in view
            NSLayoutConstraint(item: interactionsView, attribute: .top     , relatedBy: .equal, toItem: bookmarkButton, attribute: .bottom  , multiplier: 1, constant: 8),
            NSLayoutConstraint(item: interactionsView, attribute: .leading , relatedBy: .equal, toItem: self          , attribute: .leading , multiplier: 1, constant: 0),
            NSLayoutConstraint(item: interactionsView, attribute: .trailing, relatedBy: .equal, toItem: self          , attribute: .trailing, multiplier: 1, constant: 0),
            // View size
            NSLayoutConstraint(item: self, attribute: .bottomMargin, relatedBy: .equal, toItem: interactionsView, attribute: .bottom, multiplier: 1, constant: 0),
        ])
    }

    public var onComment: Optional<() -> Void> {
        set { interactionsView.onComment = newValue }
        get { interactionsView.onComment }
    }
    public var onVote: Optional<() -> Void> {
        set { interactionsView.onVote = newValue }
        get { interactionsView.onVote }
    }
    public var onShare: Optional<() -> Void> {
        set { interactionsView.onShare = newValue }
        get { interactionsView.onShare }
    }
    public var onBookmark: Optional<() -> Void> {
        set { bookmarkButton.onClick = newValue }
        get { bookmarkButton.onClick }
    }
    public var onDoubleTap: Optional<() -> Void> {
        set { thumbnail.onDoubleTap = newValue }
        get { thumbnail.onDoubleTap }
    }
        
    public func populate(bookmarked: Bool) {
        bookmarkButton.updateBookmark(bookmarked: bookmarked)
    }
    
    public func populate(post: Post?) {
        header.populate(dataFrom: post)
        selftext.text = post?.selfText
        interactionsView.populate(votes: post?.score ?? 0)
        interactionsView.populate(comments: post?.commentCount ?? 0)
        thumbnail.populate(imageFromSource: post?.preview?.images.first?.source)
    }
    
    required init?(coder: NSCoder) { nil }
    
}
