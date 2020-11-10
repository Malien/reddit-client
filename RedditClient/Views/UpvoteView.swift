//
//  UpvoteView.swift
//  RedditClient
//
//  Created by Yaroslav on 02.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import UIKit

class UpvoteView : UIButton {
    
    let icon = UIImageView().autolayouted()
    let label = UILabel().autolayouted()
    var onClick: Optional<() -> Void>
    
    init(votes: Int, onClick: Optional<() -> Void> = nil) {
        self.onClick = onClick
        super.init(frame: CGRect.zero)
        
        populate(votes: votes)
        
        addSubview(icon)
        addSubview(label)
        addTarget(self, action: #selector(handleClick), for: .touchUpInside)
        
        guard let image = icon.image else { return }
        let multiplier = image.size.height / image.size.width
        
        NSLayoutConstraint.activate([
            // Icon
            NSLayoutConstraint(item: icon, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leadingMargin, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: icon, attribute: .top    , relatedBy: .equal, toItem: self, attribute: .topMargin    , multiplier: 1, constant: 0),
            NSLayoutConstraint(item: icon, attribute: .width  , relatedBy: .equal, toItem: nil , attribute: .width        , multiplier: 1, constant: 20),
            NSLayoutConstraint(item: icon, attribute: .height , relatedBy: .equal, toItem: icon, attribute: .width        , multiplier: multiplier, constant: 0),
            // Label
            NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: icon, attribute: .trailing, multiplier: 1, constant: 8),
            NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: icon, attribute: .centerY , multiplier: 1, constant: 0),
            // Button size
            NSLayoutConstraint(item: self, attribute: .trailingMargin, relatedBy: .equal, toItem: label, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .bottomMargin  , relatedBy: .equal, toItem: icon , attribute: .bottom  , multiplier: 1, constant: 0)
        ])
    }
    
    func populate(votes: Int) {
        if votes > 0 {
            icon.image = ApplicationIcon.upvote
            icon.tintColor = .upvote
            label.text = "+\(votes.formatCount)"
            label.textColor = .upvote
        } else if votes < 0 {
            icon.image = ApplicationIcon.downvote
            icon.tintColor = .downvote
            label.text = votes.formatCount
            label.textColor = .downvote
        } else {
            icon.image = ApplicationIcon.novote
            icon.tintColor = .subtext
            label.text = votes.formatCount
            label.textColor = .text
        }
    }
    
    required init?(coder: NSCoder) { nil }

    @objc
    private func handleClick() {
        guard let onClick = onClick else { return }
        onClick()
    }
    
}
