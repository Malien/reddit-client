//
//  BookmarkButtonView.swift
//  RedditClient
//
//  Created by Yaroslav on 01.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import UIKit

class BookmarkButton: UIButton {
    
    let icon = UIImageView().autolayouted()
    let label = UILabel().autolayouted()
    
    let clickHandler: () -> Void
    
    init(bookmarked: Bool, onClick: @escaping () -> Void = {}) {
        clickHandler = onClick
        super.init(frame: CGRect.zero)
        
        updateBookmark(bookmarked: bookmarked)
        
        icon.tintColor = .accent
        label.textColor = .accent
        label.font = .bigger
        
        directionalLayoutMargins = NSDirectionalEdgeInsets(top: 12, leading: 4, bottom: 12, trailing: 12)
        
        addSubview(icon)
        addSubview(label)
        
        addTarget(self, action: #selector(handleClick), for: .touchUpInside)
        
        guard let image = icon.image else { return }
        let multiplier = image.size.height / image.size.width
        
        NSLayoutConstraint.activate([
            // Icon
            NSLayoutConstraint(item: icon, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leadingMargin, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: icon, attribute: .top    , relatedBy: .equal, toItem: self, attribute: .topMargin    , multiplier: 1, constant: 0),
            NSLayoutConstraint(item: icon, attribute: .width  , relatedBy: .equal, toItem: nil , attribute: .width        , multiplier: 1, constant: 16),
            NSLayoutConstraint(item: icon, attribute: .height , relatedBy: .equal, toItem: icon, attribute: .width        , multiplier: multiplier, constant: 0),
            // Label
            NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: icon, attribute: .trailing, multiplier: 1, constant: 12),
            NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: icon, attribute: .centerY , multiplier: 1, constant: 0),
            // Button size
            NSLayoutConstraint(item: self, attribute: .trailingMargin, relatedBy: .equal, toItem: label, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .bottomMargin  , relatedBy: .equal, toItem: icon , attribute: .bottom  , multiplier: 1, constant: 0)
        ])
    }
    
    func updateBookmark(bookmarked: Bool) {
        if bookmarked {
            icon.image = ApplicationIcon.bookmarkFilled
            label.text = "Bookmarked"
        } else {
            icon.image = ApplicationIcon.bookmarkOutlined
            label.text = "Add to bookmarks"
        }
    }
    
    required init?(coder: NSCoder) {
        return nil
//        super.init(coder: coder)
    }
    
    @objc
    private func handleClick() {
        clickHandler()
    }
}
