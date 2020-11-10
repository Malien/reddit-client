//
//  PostInteractionsView.swift
//  RedditClient
//
//  Created by Yaroslav on 01.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import UIKit

class PostInteractionsView : UIView {
    
    private let votes: UpvoteView
    private let comments = LabeledButton(icon: ApplicationIcon.comments, label: "4").autolayouted()
    private let share = LabeledButton(icon: ApplicationIcon.share ,label: "Share").autolayouted()
    
    public var onComment: Optional<() -> Void> {
        set { comments.onClick = newValue }
        get { comments.onClick }
    }
    public var onShare: Optional<() -> Void> {
        set { share.onClick = newValue }
        get { share.onClick }
    }
    public var onVote: Optional<() -> Void> {
        set { votes.onClick = newValue }
        get { votes.onClick }
    }

    init(votes voteCount: Int) {
        votes = UpvoteView(votes: voteCount).autolayouted()
        super.init(frame: CGRect.zero)
        
        directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)

        func makeLine() -> UIView {
            let line = UIView().autolayouted()
            line.backgroundColor = .subtext
            line.layer.cornerRadius = 1
            return line
        }
        
        let topLine = makeLine()
        let bottomLine = makeLine()
        
        addSubview(votes)
        addSubview(comments)
        addSubview(share)
        addSubview(topLine)
        addSubview(bottomLine)
        
        NSLayoutConstraint.activate([
            // Votes
            NSLayoutConstraint(item: votes, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leadingMargin, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: votes, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY      , multiplier: 1, constant: 0),
            // Comments
            NSLayoutConstraint(item: comments, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: comments, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0),
            // Share
            NSLayoutConstraint(item: share, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailingMargin, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: share, attribute: .centerY , relatedBy: .equal, toItem: self, attribute: .centerY       , multiplier: 1, constant: 0),
            // Top line
            NSLayoutConstraint(item: topLine, attribute: .height  , relatedBy: .equal, toItem: nil , attribute: .height        , multiplier: 1, constant: 1),
            NSLayoutConstraint(item: topLine, attribute: .leading , relatedBy: .equal, toItem: self, attribute: .leadingMargin , multiplier: 1, constant: 0),
            NSLayoutConstraint(item: topLine, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailingMargin, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: topLine, attribute: .top     , relatedBy: .equal, toItem: self, attribute: .topMargin     , multiplier: 1, constant: 0),
            // Bottom line
            NSLayoutConstraint(item: bottomLine, attribute: .height  , relatedBy: .equal, toItem: nil , attribute: .height        , multiplier: 1, constant: 1),
            NSLayoutConstraint(item: bottomLine, attribute: .leading , relatedBy: .equal, toItem: self, attribute: .leadingMargin , multiplier: 1, constant: 0),
            NSLayoutConstraint(item: bottomLine, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailingMargin, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: bottomLine, attribute: .bottom  , relatedBy: .equal, toItem: self, attribute: .bottomMargin  , multiplier: 1, constant: 0),
            // View size
            NSLayoutConstraint(item: self, attribute: .height      , relatedBy: .greaterThanOrEqual, toItem: nil     , attribute: .height, multiplier: 1, constant: 40),
            NSLayoutConstraint(item: self, attribute: .bottomMargin, relatedBy: .greaterThanOrEqual, toItem: votes   , attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .bottomMargin, relatedBy: .greaterThanOrEqual, toItem: comments, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .bottomMargin, relatedBy: .greaterThanOrEqual, toItem: share   , attribute: .bottom, multiplier: 1, constant: 0),
        ])
    }
    
    func populate(votes voteCount: Int) {
        votes.populate(votes: voteCount)
    }
    
    required init?(coder: NSCoder) { nil }
}
