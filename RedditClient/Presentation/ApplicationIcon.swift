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
}

enum ApplicationIcon {
    static let bookmarkFilled = UIImage.fromCatalog(named: "icon.bookmark.fill").withRenderingMode(.alwaysTemplate)
    static let bookmarkOutlined = UIImage.fromCatalog(named: "icon.bookmark.outline")
}
