//
//  PostTableViewCell.swift
//  RedditClient
//
//  Created by Yaroslav on 08.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import UIKit

protocol ReusableCell {
    static var reuseIdentifier: String { get }
}

extension UITableView {
//    func register(reusableCellClass: ReusableCell)
}

class PostTableViewCell: UITableViewCell {
    
    static let reuseIndentifier = "postCell"
    
    let postView = PostView(post: nil).autolayouted()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(postView)

        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: postView   , attribute: .leading , relatedBy: .equal, toItem: contentView, attribute: .leading , multiplier: 1, constant: 0),
            NSLayoutConstraint(item: postView   , attribute: .top     , relatedBy: .equal, toItem: contentView, attribute: .top     , multiplier: 1, constant: 0),
            NSLayoutConstraint(item: postView   , attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: contentView, attribute: .bottom  , relatedBy: .equal, toItem: postView   , attribute: .bottom  , multiplier: 1, constant: 0)
        ])
    }
    
    override func prepareForReuse() {
        postView.populate(post: nil)
    }
    
    func populate(post: Post) {
        postView.populate(post: post)
    }
    
    func populate(bookmarked: Bool) {
        postView.populate(bookmarked: bookmarked)
    }
    
    required init?(coder: NSCoder) { nil }

}
