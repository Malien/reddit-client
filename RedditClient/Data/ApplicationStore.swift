import Foundation

final class ApplicationStore {
    var subredditTopPosts = Cache<TopPostsRequest, PaginationContainer<Post>>()
    #if CACHE_POSTS
    var posts = Cache<PostID, Post>()
    #endif
    var saved = SavedPosts()
}

extension ApplicationStore: Codable {
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
