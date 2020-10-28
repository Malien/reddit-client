//
//  PostPreview.swift
//  RedditClient
//
//  Created by Yaroslav on 28.10.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import Foundation

struct PostPreview: Codable {
    let images: [ImageDescription]
    let enabled: Bool
}
