import Foundation

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