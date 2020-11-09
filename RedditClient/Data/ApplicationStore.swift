import Foundation

final class ApplicationStore {
    var subredditTopPosts: Cache<TopPostsRequest, PaginationContainer<Post>>

    init(
        subredditTopPosts: Cache<TopPostsRequest, PaginationContainer<Post>> = Cache()
    ) {
        self.subredditTopPosts = subredditTopPosts
    }
}

extension ApplicationStore: Codable {
//    enum CodingKeys: String, CodingKey {
//        case subredditTopPosts
//    }

//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(subredditTopPosts, forKey: .subredditTopPosts)
//    }
//
//    convenience init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        let subredditTopPosts = try container.decode(
//            Cache<TopPostsRequest, [Post]>.self, forKey: .subredditTopPosts)
//        self.init(subredditTopPosts: subredditTopPosts)
//    }

    struct NoCacheDir: Error {}

    func persist(version: String) throws {
        let cachesDirs = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        guard let cacheFile = cachesDirs.first?.appendingPathComponent("\(version).cache.json")
        else {
            throw NoCacheDir()
        }
        let data = try JSONEncoder().encode(self)
        try data.write(to: cacheFile)
    }

    func load(version: String) throws -> ApplicationStore {
        let cachesDirs = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        guard let cacheFile = cachesDirs.first?.appendingPathComponent("\(version).cache.json")
        else {
            throw NoCacheDir()
        }
        let data = try Data(contentsOf: cacheFile)
        return try JSONDecoder().decode(ApplicationStore.self, from: data)
    }
}
