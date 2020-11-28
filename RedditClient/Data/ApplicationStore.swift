import Foundation
import os

final class ApplicationStore {
    // TODO: Normalize cache
    var subredditTopPosts: Cache<TopPostsRequest, PaginationContainer<Post>>
    var posts: Cache<PostID, Post>
    var saved: SavedPosts
    var postComments: Cache<CommentsRequest, PaginationContainer<Comment>>
    private var postsSub: Cache<PostID, Post>.SubID!
    private var savedSub: SavedPosts.SubID!
    private(set) var initiateSave: () -> Void = {}
    
    init(
        subredditTopPosts: Cache<TopPostsRequest, PaginationContainer<Post>> = Cache(),
        posts: Cache<PostID, Post> = Cache(),
        saved: SavedPosts = SavedPosts(),
        postComments: Cache<CommentsRequest, PaginationContainer<Comment>> = Cache()
    ) {
        self.subredditTopPosts = subredditTopPosts
        self.posts = posts
        self.saved = saved
        self.postComments = postComments

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
                self?.saved.update(postWithID: id, to: post)
            default:
                break
            }
        }
        
        savedSub = self.saved.subscribe { _ in
            self.initiateSave()
        }
    }
    
    deinit {
        posts.unsubscribe(postsSub)
        saved.unsubscribe(savedSub)
    }
}

extension ApplicationStore: Codable {
    struct NoCacheDir: Error {}
    
    enum CodingKeys: String, CodingKey {
        case saved
    }
    
    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let subredditTopPosts = Cache<TopPostsRequest, PaginationContainer<Post>>()
        let posts = Cache<PostID, Post>()
        let saved = try container.decode(SavedPosts.self, forKey: .saved)
        self.init(subredditTopPosts: subredditTopPosts, posts: posts, saved: saved)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(saved, forKey: .saved)
    }
    
    func persist(version: String) throws {
        let cachesDirs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let cacheFile = cachesDirs.first?.appendingPathComponent("\(version).store.json")
            else { throw NoCacheDir() }
        #if DEBUG
        print("Save location \(cacheFile)")
        #endif
        let data = try JSONEncoder().encode(self)
        try data.write(to: cacheFile)
    }

    static func load(version: String) throws -> ApplicationStore {
        let cachesDirs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let cacheFile = cachesDirs.first?.appendingPathComponent("\(version).store.json")
            else { throw NoCacheDir() }
        let data = try Data(contentsOf: cacheFile)
        return try JSONDecoder().decode(ApplicationStore.self, from: data)
    }
}
