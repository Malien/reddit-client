//
//  Commons.swift
//  RedditClient
//
//  Created by Yaroslav on 01.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import UIKit

extension UIColor {
    static func fromCatalog(named: StaticString) -> UIColor {
        guard let color = UIColor(named: named.description) else {
            preconditionFailure("Color \(named) is not found in the asset catalogue")
        }
        return color
    }
    
    static let background = UIColor.fromCatalog(named: "color.background")
    static let accent = UIColor.fromCatalog(named: "color.accent")
    static let upvote = UIColor.fromCatalog(named: "color.upvote")
    static let downvote = UIColor.fromCatalog(named: "color.downvote")
    static let text = UIColor.fromCatalog(named: "color.text")
    static let subtext = UIColor.fromCatalog(named: "color.subtext")
}
