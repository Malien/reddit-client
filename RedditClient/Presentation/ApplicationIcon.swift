//
//  ApplicationIcon.swift
//  RedditClient
//
//  Created by Yaroslav on 01.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import UIKit

extension UIImage {
    static func fromCatalog(named: StaticString) -> UIImage {
        guard let image = UIImage(named: named.description) else {
            preconditionFailure("No image \(named) found in asset catalog")
        }
        return image
    }
    
    static func applicationIcon(named: StaticString) -> UIImage {
        guard let image = UIImage(named: "icon.\(named)") else {
            preconditionFailure("No image \(named) found in asset catalog")
        }
        return image.withRenderingMode(.alwaysTemplate)
    }
}

enum ApplicationIcon {
    static let bookmarkFilled = UIImage.applicationIcon(named: "bookmark.fill")
    static let bookmarkOutlined = UIImage.applicationIcon(named: "bookmark.outline")
    static let comments = UIImage.applicationIcon(named: "bauble")
    static let share = UIImage.applicationIcon(named: "share")
    static let upvote = UIImage.applicationIcon(named: "upvote")
    static let downvote = UIImage.applicationIcon(named: "downvote")
    static let novote = UIImage.applicationIcon(named: "novote")
}
