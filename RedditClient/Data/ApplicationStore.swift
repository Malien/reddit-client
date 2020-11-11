import Foundation
import os

final class ApplicationStore {
    // TODO: Normalize cache
    var subredditTopPosts: Cache<TopPostsRequest, PaginationContainer<Post>>
    var posts: Cache<PostID, Post>
    var saved: SavedPosts
    private var postsSub: Cache<PostID, Post>.SubID! = nil
    #if PERSIST_CACHES
    private var topPostsSub: Cache<TopPostsRequest, PaginationContainer<Post>>.SubID! = nil
    #endif
    private var savedSub: SavedPosts.SubID! = nil
    private(set) var initiateSave: (() -> Void) = {}
    
    init(
        subredditTopPosts: Cache<TopPostsRequest, PaginationContainer<Post>> = Cache(),
        posts: Cache<PostID, Post> = Cache(),
        saved: SavedPosts = SavedPosts()
    ) {
        self.subredditTopPosts = subredditTopPosts
        self.posts = posts
        self.saved = saved

        initiateSave = debounce(timeout: .seconds(1), queue: ApplicationServices.ioQueue) {
            do {
                try self.persist(version: ApplicationServices.version)
            } catch let error {
                print(error)
            }
        }
        
        postsSub = self.posts.subscribe { [weak self] event in
            switch event {
            case .updated(let id, let post):
                #if PERSIST_CACHES
                self?.initiateSave()
                #endif
                self?.saved.update(postWithID: id, to: post)
            default:
                break
            }
        }
        
        #if PERSIST_CACHES
        topPostsSub = self.subredditTopPosts.subscribe { [weak self] event in
            switch event {
            case .updated(_, _):
                self?.initiateSave()
            default:
                break
            }
        }
        #endif
        savedSub = self.saved.subscribe { _ in
            self.initiateSave()
        }
    }
    
    deinit {
        posts.unsubscribe(postsSub)
        #if PERSIST_CACHES
        subredditTopPosts.unsubscribe(topPostsSub)
        #endif
        saved.unsubscribe(savedSub)
    }
}

extension ApplicationStore: Codable {
    struct NoCacheDir: Error {}
    
    enum CodingKeys: String, CodingKey {
        #if PERSIST_CACHES
        case subredditTopPosts
        case posts
        #endif
        case saved
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        #if PERSIST_CACHES
        let subredditTopPosts = try container.decode(Cache<TopPostsRequest, PaginationContainer<Post>>.self, forKey: .subredditTopPosts)
        let posts = try container.decode(Cache<PostID, Post>.self, forKey: .posts)
        #else
        let subredditTopPosts = Cache<TopPostsRequest, PaginationContainer<Post>>()
        let posts = Cache<PostID, Post>()
        #endif
        let saved = try container.decode(SavedPosts.self, forKey: .saved)
        self.init(subredditTopPosts: subredditTopPosts, posts: posts, saved: saved)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        #if PERSIST_CACHES
        try container.encode(subredditTopPosts, forKey: .subredditTopPosts)
        try container.encode(posts, forKey: .posts)
        #endif
        try container.encode(saved, forKey: .saved)
    }
    
    func persist(version: String) throws {
        #if PERSIST_CACHES
        let cachesDirs = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        guard let cacheFile = cachesDirs.first?.appendingPathComponent("\(version).cache.json")
            else { throw NoCacheDir() }
        #else
        let cachesDirs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let cacheFile = cachesDirs.first?.appendingPathComponent("\(version).store.json")
            else { throw NoCacheDir() }
        #endif
        #if DEBUG
        print("Save location \(cacheFile)")
        #endif
        let data = try JSONEncoder().encode(self)
        try data.write(to: cacheFile)
    }

    static func load(version: String) throws -> ApplicationStore {
        #if PERSIST_CACHES
        let cachesDirs = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        guard let cacheFile = cachesDirs.first?.appendingPathComponent("\(version).cache.json")
            else { throw NoCacheDir() }
        #else
        let cachesDirs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let cacheFile = cachesDirs.first?.appendingPathComponent("\(version).store.json")
            else { throw NoCacheDir() }
        #endif
        let data = try Data(contentsOf: cacheFile)
        return try JSONDecoder().decode(ApplicationStore.self, from: data)
    }
}
