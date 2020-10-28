//
//  ImageDescription.swift
//  RedditClient
//
//  Created by Yaroslav on 28.10.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import Foundation

/// This a collection of image properties transfered from an API
struct ImageDescription: Codable, Identifiable {
    let id: String
    let source: Source
    let resolutions: [Source]
    /// Theese are usually only set on nsfw images, and typically are blured versions of the original image
    let variants: Variants
    
    struct Source: Codable {
        let url: URL
        let width: Int
        let height: Int
    }
    
    struct Variants: Codable {
        let obfuscated: CoreImage?
        let nsfw: CoreImage?
    }
    
    struct CoreImage: Codable {
        let source: Source
        let resolutions: [Source]
    }
}
