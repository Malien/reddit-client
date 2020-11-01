//
//  PostView.swift
//  RedditClient
//
//  Created by Yaroslav on 28.10.2020.
//  Copytrailing © 2020 Yaroslav. All rights reserved.
//

import UIKit
import SDWebImage

class PostView : UIView {
    
    let header: PostHeaderView
    // TODO: Come up with declarative way of handling appearing and disappearing views
    let thumbnail = UIImageView().autolayouted()
    var thumbnailHeightConstraint: NSLayoutConstraint

    init(post: Post) {
        header = PostHeaderView(post: post).autolayouted()
        thumbnailHeightConstraint = NSLayoutConstraint(item: thumbnail, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 0)
        super.init(frame: CGRect.zero)

        populate(dataFrom: post)
        
        addSubview(header)
        addSubview(thumbnail)

        NSLayoutConstraint.activate([
            // Header in view
            NSLayoutConstraint(item: header, attribute: .leading , relatedBy: .equal, toItem: self , attribute: .leading , multiplier: 1, constant: 0),
            NSLayoutConstraint(item: header, attribute: .top     , relatedBy: .equal, toItem: self , attribute: .top     , multiplier: 1, constant: 0),
            NSLayoutConstraint(item: header, attribute: .trailing, relatedBy: .equal, toItem: self , attribute: .trailing, multiplier: 1, constant: 0),
            // Thumbnail in view
            NSLayoutConstraint(item: thumbnail, attribute: .top     , relatedBy: .equal, toItem: header, attribute: .bottom  , multiplier: 1, constant: 0),
            NSLayoutConstraint(item: thumbnail, attribute: .leading , relatedBy: .equal, toItem: self  , attribute: .leading , multiplier: 1, constant: 0),
            NSLayoutConstraint(item: thumbnail, attribute: .trailing, relatedBy: .equal, toItem: self  , attribute: .trailing, multiplier: 1, constant: 0),
            thumbnailHeightConstraint,
            // View size
            NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: thumbnail, attribute: .bottom, multiplier: 1, constant: 0),
        ])
    }
    
    public func populate(dataFrom post: Post) {
        header.populate(dataFrom: post)
        if let preview = post.preview, let image = preview.images.first {
            thumbnail.sd_setImage(with: image.source.url) { [weak self] (_, _, _, _) in
                guard let self = self else { return }
                let multiplier = CGFloat(image.source.height) / CGFloat(image.source.width)
                self.thumbnailHeightConstraint.isActive = false
                self.thumbnailHeightConstraint = NSLayoutConstraint(
                    item: self.thumbnail,
                    attribute: .height,
                    relatedBy: .equal,
                    toItem: self.thumbnail,
                    attribute: .width,
                    multiplier: multiplier,
                    constant: 0
                )
                self.thumbnailHeightConstraint.isActive = true
            }
        } else {
            thumbnail.image = nil
        }
    }
    
    required init?(coder: NSCoder) {
        header = PostHeaderView(coder: coder)!
        thumbnailHeightConstraint = NSLayoutConstraint(item: thumbnail, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 0)
        super.init(coder: coder)
    }
    
}
