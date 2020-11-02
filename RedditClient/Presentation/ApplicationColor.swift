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
    
    static func applicationColor(named: StaticString) -> UIColor {
        guard let color = UIColor(named: "color.\(named)") else {
            preconditionFailure("Color \(named) is not found in the asset catalogue")
        }
        return color
    }
    
    static let background = UIColor.applicationColor(named: "background")
    static let accent = UIColor.applicationColor(named: "accent")
    static let upvote = UIColor.applicationColor(named: "upvote")
    static let downvote = UIColor.applicationColor(named: "downvote")
    static let text = UIColor.applicationColor(named: "text")
    static let subtext = UIColor.applicationColor(named: "subtext")
}
