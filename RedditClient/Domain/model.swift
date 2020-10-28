import Foundation

// MARK: RedditEntity

/// Reddit types out their entities like such
/// ```ts
/// {
///     "kind": "listing" | "t1" | "t2" | "t3" | "t4" | "t5" | "t6"
///     "data": // actual entity fields
/// }
/// ```
/// This is done solely for type-checking purposes
protocol RedditEntity where Self: Codable {
    static var kind: String { get }
}

// MARK: PostID

/// Type to differenciate in code between PostID, CommentID etc.
struct PostID: Hashable {
    let id: String
    init(_ id: String) { self.id = id }
}

extension PostID: Encodable, Decodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(id)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.id = try container.decode(String.self)
    }
}

// MARK: Thumbnail
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

// MARK: Vote
/// Voting value is represented as either `true` (upvoted), `false` (downvoted) or `null` (no vote)
/// This is an adapter to make those values a bit more "swifty"
enum Vote {
    case up
    case down
    case none
}

extension Vote: Codable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .up: try container.encode(true)
        case .down: try container.encode(false)
        case .none: try container.encodeNil()
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .none
        } else if try container.decode(Bool.self) {
            self = .up
        } else {
            self = .down
        }
    }
}

// MARK: ImageDescription
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

// MARK: PostPreview
struct PostPreview: Codable {
    let images: [ImageDescription]
    let enabled: Bool
}

// MARK: Post

/// This is a post, but throughout reddit api doccumentations
/// it is refered to as a link for some reason
/// This is both, serialization container for reddit API responses, and domain model object
struct Post: RedditEntity, Identifiable {
    static var kind: String { "t3" }

    let id: PostID
    /// fullname property (a combination of `kind` and `id`, like `t3_ji8ght`)
    let name: String

    // Upvotes. Fuzzed to prevent bot spam
    let ups: Int
    // Downvotes. Fuzzed to prevent bit spam
    let downs: Int
    /// User vote
    let likes: Vote

    let createdEpoch: TimeInterval
    let createdUTCEpoch: TimeInterval
    lazy var created = Date.init(timeIntervalSince1970: createdEpoch)
    lazy var createdUTC = Date.init(timeIntervalSince1970: createdUTCEpoch)

    /// If link is promotional, author is set to `nil`
    let author: String?
    let clicked: Bool
    let domain: String
    let hidden: Bool
    let isSelf: Bool
    let locked: Bool
    let numComents: Int
    let over18: Bool
    let permalink: URL
    let saved: Bool
    /// Always accurate, despite ups and downs being fuzzed
    let score: Int
    let selfText: String
    let selfTextHTML: String?
    let subreddit: String
    let subredditID: String
    let thumbnail: Thumbnail
    let title: String
    let url: URL
    let stickied: Bool
    let archived: Bool
    let pinned: Bool

    let preview: PostPreview?

    enum CodingKeys: String, CodingKey {
        case id
        case name

        case ups
        case downs
        case likes

        case createdEpoch = "created"
        case createdUTCEpoch = "created_utc"

        case author
        case clicked
        case domain
        case hidden
        case isSelf = "is_self"
        case locked
        case numComents = "num_comments"
        case over18 = "over_18"
        case permalink
        case saved
        case score
        case selfText = "selftext"
        case selfTextHTML = "selftext_html"
        case subreddit
        case subredditID = "subreddit_id"
        case thumbnail
        case title
        case url
        case stickied
        case archived
        case pinned
        case preview

    }
}
