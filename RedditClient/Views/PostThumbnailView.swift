//
//  PostThumbnailView.swift
//  RedditClient
//
//  Created by Yaroslav on 18.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    func prioritized(_ priority: UILayoutPriority) -> Self {
        self.priority = priority
        return self
    }
}

final class PostThumbnailView: UIView {

    private let thumbnail = UIImageView().autolayouted()
    private var thumbnailHeightConstraint: NSLayoutConstraint
    private let tapView = BookmarkIconView().autolayouted()
    var onDoubleTap: Optional<() -> Void>
    
    @objc
    private func handleDoubleTap() {
        tapView.animateSplash()
        guard let onDoubleTap = onDoubleTap else { return }
        onDoubleTap()
    }

    init(imageFromSource source: ImageDescription.Source? = nil, onDoubleTap: Optional<() -> Void> = nil) {
        self.onDoubleTap = onDoubleTap
        thumbnailHeightConstraint = NSLayoutConstraint(item: thumbnail, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 0)
        super.init(frame: CGRect.zero)
        
        populate(imageFromSource: source)
        
        let recognizer = UITapGestureRecognizer()
        recognizer.numberOfTapsRequired = 2
        recognizer.addTarget(self, action: #selector(handleDoubleTap))
        addGestureRecognizer(recognizer)

        addSubview(thumbnail)
        addSubview(tapView)

        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: thumbnail, attribute: .leading , relatedBy: .equal, toItem: self, attribute: .leading , multiplier: 1, constant: 0),
            NSLayoutConstraint(item: thumbnail, attribute: .top     , relatedBy: .equal, toItem: self, attribute: .top     , multiplier: 1, constant: 0),
            NSLayoutConstraint(item: thumbnail, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: thumbnail, attribute: .bottom  , relatedBy: .equal, toItem: self, attribute: .bottom  , multiplier: 1, constant: 0),
            
            NSLayoutConstraint(item: tapView, attribute: .centerX, relatedBy: .equal          , toItem: self   , attribute: .centerX, multiplier: 1  , constant: 0),
            NSLayoutConstraint(item: tapView, attribute: .centerY, relatedBy: .equal          , toItem: self   , attribute: .centerY, multiplier: 1  , constant: 0),
            NSLayoutConstraint(item: tapView, attribute: .width  , relatedBy: .lessThanOrEqual, toItem: self   , attribute: .width  , multiplier: 0.8, constant: 0)
                .prioritized(.required),
            NSLayoutConstraint(item: tapView, attribute: .height , relatedBy: .lessThanOrEqual, toItem: self   , attribute: .height , multiplier: 0.8, constant: 0)
                .prioritized(.required),
            NSLayoutConstraint(item: tapView, attribute: .width  , relatedBy: .equal          , toItem: self   , attribute: .width  , multiplier: 0.8, constant: 0)
                .prioritized(.defaultHigh),
            NSLayoutConstraint(item: tapView, attribute: .height , relatedBy: .equal          , toItem: self   , attribute: .height , multiplier: 0.8, constant: 0)
                .prioritized(.defaultHigh),
            NSLayoutConstraint(item: tapView, attribute: .width  , relatedBy: .equal          , toItem: tapView, attribute: .height , multiplier: 0.75  , constant: 0)
                .prioritized(.required),
        ])
    }
    

    func populate(imageFromSource source: ImageDescription.Source?) {
        if let source = source {
            let multiplier = CGFloat(source.height) / CGFloat(source.width)
            self.thumbnailHeightConstraint.isActive = false
            self.thumbnailHeightConstraint = NSLayoutConstraint(
                item: self,
                attribute: .height,
                relatedBy: .equal,
                toItem: self,
                attribute: .width,
                multiplier: multiplier,
                constant: 0
            )
            self.thumbnailHeightConstraint.isActive = true
            thumbnail.sd_setImage(with: source.url)
        } else {
            thumbnail.image = nil
            self.thumbnailHeightConstraint.isActive = false
            self.thumbnailHeightConstraint = NSLayoutConstraint(
                item: self,
                attribute: .height,
                relatedBy: .equal,
                toItem: nil,
                attribute: .height,
                multiplier: 1,
                constant: 0
            )
            self.thumbnailHeightConstraint.isActive = true
        }
    }
    
    required init?(coder: NSCoder) { nil }

}
