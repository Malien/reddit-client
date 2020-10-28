//
//  Thumbnail.swift
//  RedditClient
//
//  Created by Yaroslav on 28.10.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import Foundation

/// Thumbnail is usually an url to the image. But there are a few special cases.
/// Instead of url there can be keywords: `"self"`, `"image"`, `"nsfw"` and `"default"`
enum Thumbnail {
    case `self`
    case image
    case nsfw
    case `default`
    case url(URL)
}

extension Thumbnail: Codable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .`self`: try container.encode("self")
        case .image: try container.encode("image")
        case .nsfw: try container.encode("nsfw")
        case .`default`: try container.encode("default")
        case .url(let url): try container.encode(url)
        }
    }
    
    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        switch value {
        case "self": self = .`self`
        case "image": self = .image
        case "nsfw": self = .nsfw
        case "default": self = .`default`
        default:
            guard let url = URL(string: value) else {
                throw Swift.EncodingError.invalidValue(
                    value,
                    EncodingError.Context.init(
                        codingPath: decoder.codingPath,
                        debugDescription: "Thumbnail value is not an url or other known value"))
            }
            self = .url(url)
        }
    }
}

