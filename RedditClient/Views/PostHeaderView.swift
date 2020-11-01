//
//  PostHeaderView.swift
//  RedditClient
//
//  Created by Yaroslav on 01.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import UIKit

class PostHeaderView : UIView {
    
    let username = UILabel().autolayouted()
    let timestamp = UILabel().autolayouted()
    let subreddit = UILabel().autolayouted()
    let title = UILabel().autolayouted()
    
    init(post: Post) {
        super.init(frame: CGRect.zero)
        
        populate(dataFrom: post)
        
        /// Might want to use `layoutMargins` as trailing and leading margins are the same, this might give ability to target iOS < 11
        directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)

        username.textColor = .accent
        username.font = .defaultText
        
        timestamp.textColor = .subtext
        timestamp.font = .defaultText
        
        subreddit.textColor = .subtext
        subreddit.font = .defaultText
        
        title.numberOfLines = 3
        title.textColor = .text
        title.font = .title

        func makeDot() -> UILabel {
            let dot = UILabel().autolayouted()
            dot.text = "•"
            dot.textColor = .text
            return dot
        }
        
        let dot1 = makeDot()
        let dot2 = makeDot()
        
        addSubview(username)
        addSubview(dot1)
        addSubview(timestamp)
        addSubview(dot2)
        addSubview(subreddit)
        addSubview(title)

        NSLayoutConstraint.activate([
            // Username in header
            NSLayoutConstraint(item: username, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leadingMargin, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: username, attribute: .top    , relatedBy: .equal, toItem: self, attribute: .topMargin    , multiplier: 1, constant: 0),
            // Dot in header
            NSLayoutConstraint(item: dot1, attribute: .leading, relatedBy: .equal, toItem: username, attribute: .trailing, multiplier: 1, constant: 5),
            NSLayoutConstraint(item: dot1, attribute: .centerY, relatedBy: .equal, toItem: username, attribute: .centerY , multiplier: 1, constant: 0),
            // Timestamp in header
            NSLayoutConstraint(item: timestamp, attribute: .leading, relatedBy: .equal, toItem: dot1, attribute: .trailing, multiplier: 1, constant: 5),
            NSLayoutConstraint(item: timestamp, attribute: .centerY, relatedBy: .equal, toItem: dot1, attribute: .centerY , multiplier: 1, constant: 0),
            // Dot in header
            NSLayoutConstraint(item: dot2, attribute: .leading, relatedBy: .equal, toItem: timestamp, attribute: .trailing, multiplier: 1, constant: 5),
            NSLayoutConstraint(item: dot2, attribute: .centerY, relatedBy: .equal, toItem: timestamp, attribute: .centerY , multiplier: 1, constant: 0),
            // Subreddit in header
            NSLayoutConstraint(item: subreddit, attribute: .leading, relatedBy: .equal, toItem: dot2, attribute: .trailing, multiplier: 1, constant: 5),
            NSLayoutConstraint(item: subreddit, attribute: .centerY, relatedBy: .equal, toItem: dot2, attribute: .centerY , multiplier: 1, constant: 0),
            // Post title in header
            NSLayoutConstraint(item: title, attribute: .top     , relatedBy: .equal, toItem: username, attribute: .bottom        , multiplier: 1, constant: 5),
            NSLayoutConstraint(item: title, attribute: .trailing, relatedBy: .equal, toItem: self    , attribute: .trailingMargin, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: title, attribute: .leading , relatedBy: .equal, toItem: self    , attribute: .leadingMargin , multiplier: 1, constant: 0),
            // Header size
            NSLayoutConstraint(item: self, attribute: .bottomMargin  , relatedBy: .equal, toItem: title, attribute: .bottom  , multiplier: 1, constant: 0),
        ])
    }
    
    public func populate(dataFrom post: Post) {
        username.text = "u/\(post.author ?? "promotion")"
        timestamp.text = post.userReadableTimeDiff
        subreddit.text = "r/\(post.subreddit)"
        title.text = post.title
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
