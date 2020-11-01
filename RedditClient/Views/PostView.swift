//
//  PostView.swift
//  RedditClient
//
//  Created by Yaroslav on 28.10.2020.
//  Copytrailing © 2020 Yaroslav. All rights reserved.
//

import UIKit

extension UIView {
    @discardableResult
    func autolayouted() -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }
}

class PostView : UIView {
    
    let username = UILabel().autolayouted()
    let timestamp = UILabel().autolayouted()
    let subreddit = UILabel().autolayouted()
    let title = UILabel().autolayouted()
    
    init(post: Post) {
        super.init(frame: CGRect.zero)

        populate(dataFrom: post)
        
        title.numberOfLines = 3
        
        func makeDot() -> UILabel {
            let dot = UILabel().autolayouted()
            dot.text = "•"
            return dot
        }
        
        let dot1 = makeDot()
        let dot2 = makeDot()

        let header = UIView().autolayouted()
        header.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        header.addSubview(username)
        header.addSubview(dot1)
        header.addSubview(timestamp)
        header.addSubview(dot2)
        header.addSubview(subreddit)
        header.addSubview(title)

        self.addSubview(header)

        NSLayoutConstraint.activate([
            // Username in header
            NSLayoutConstraint(item: username, attribute: .leading, relatedBy: .equal, toItem: header, attribute: .leadingMargin, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: username, attribute: .top    , relatedBy: .equal, toItem: header, attribute: .topMargin    , multiplier: 1, constant: 0),
            // Dot in header
            NSLayoutConstraint(item: dot1, attribute: .leading, relatedBy: .equal, toItem: username, attribute: .trailing, multiplier: 1, constant: 5),
            NSLayoutConstraint(item: dot1, attribute: .centerY, relatedBy: .equal, toItem: username, attribute: .centerY , multiplier: 1, constant: 0),
            // Timestamp in header
            NSLayoutConstraint(item: timestamp, attribute: .leading, relatedBy: .equal, toItem: dot1, attribute: .trailing, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: timestamp, attribute: .centerY, relatedBy: .equal, toItem: dot1, attribute: .centerY , multiplier: 1, constant: 0),
            // Dot in header
            NSLayoutConstraint(item: dot2, attribute: .leading, relatedBy: .equal, toItem: timestamp, attribute: .trailing, multiplier: 1, constant: 5),
            NSLayoutConstraint(item: dot2, attribute: .centerY, relatedBy: .equal, toItem: timestamp, attribute: .centerY , multiplier: 1, constant: 0),
            // Subreddit in header
            NSLayoutConstraint(item: subreddit, attribute: .leading, relatedBy: .equal, toItem: dot2, attribute: .trailing, multiplier: 1, constant: 5),
            NSLayoutConstraint(item: subreddit, attribute: .centerY, relatedBy: .equal, toItem: dot2, attribute: .centerY , multiplier: 1, constant: 0),
            // Post title in header
            NSLayoutConstraint(item: title, attribute: .top     , relatedBy: .equal, toItem: username, attribute: .bottom        , multiplier: 1, constant: 0),
            NSLayoutConstraint(item: title, attribute: .trailing, relatedBy: .equal, toItem: header  , attribute: .trailingMargin, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: title, attribute: .leading , relatedBy: .equal, toItem: header  , attribute: .leadingMargin , multiplier: 1, constant: 0),
            // Header in view
            NSLayoutConstraint(item: header, attribute: .leading , relatedBy: .equal, toItem: self , attribute: .leading , multiplier: 1, constant: 0),
            NSLayoutConstraint(item: header, attribute: .top     , relatedBy: .equal, toItem: self , attribute: .top     , multiplier: 1, constant: 0),
            NSLayoutConstraint(item: header, attribute: .trailing, relatedBy: .equal, toItem: self , attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: header, attribute: .bottom  , relatedBy: .equal, toItem: title, attribute: .bottom  , multiplier: 1, constant: 0),
            // View size
            NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: header, attribute: .bottom, multiplier: 1, constant: 0),
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
