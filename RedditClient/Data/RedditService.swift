import Foundation

struct TopPostsRequest: Hashable, Codable {
    let subreddit: Subreddit
    let start: PostID?
}

//struct PostsRequest: Hashable {
//    let ids: [PostID]
//}
//
//extension PostsRequest: Codable {
//    init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        self.ids = try container.decode([PostID].self)
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//        try container.encode(ids)
//    }
//}

/// I'll be honest, it is a bit redundant. All of this logic can as well be inside of the `RedditRepository`
/// But it forced me to make `ApplicationStore` and to make it a class
struct RedditService {
    let store: ApplicationStore
    let api = RedditAPI()
    
    private static func handleError<T>(_ result: Result<T, RedditAPI.Error>, onError: (RedditAPI.Error) -> Void, onSuccess: (T) -> Void) {
        switch result {
        case .success(let value):
            onSuccess(value)
        case .failure(let error):
            onError(error)
        }
    }

    func fetchTopPosts(
        request: TopPostsRequest,
        limit: Int? = nil,
        after: PostID? = nil,
        onError: @escaping (RedditAPI.Error) -> Void
    ) -> Cancellable {
        var cancellable: [Cancellable] = []
        let cancellation = api.topPosts(from: request.subreddit, limit: limit, after: after) { response in
            Self.handleError(response, onError: onError) { listing in
                let fetchMore = { (limit: Int, after: Post.Key?) -> Void in
                    let cancellation = self.fetchTopPosts(request: request, limit: limit, after: after) { error in
                        onError(error)
                    }
                    cancellable.append(cancellation)
                }
                for post in listing.children {
                    self.store.posts[post.inner.id] = post.inner
                }
                if var container = self.store.subredditTopPosts[request] {
                    // TODO: check if same request called multiple times
                    container.items += listing.children.map { $0.inner }
                    container.doFetch = fetchMore
                    container.hasMore = listing.dist == limit
                    self.store.subredditTopPosts[request] = container
                } else {
                    let items = listing.children.map { $0.inner }
                    let container = PaginationContainer(
                        items: items,
                        start: request.start,
                        hasMore: listing.dist == limit,
                        doFetch: fetchMore
                    )
                    self.store.subredditTopPosts[request] = container
                }
            }
        }
        cancellable.append(cancellation)
        return cancellable
    }
    
    // TODO: maybe add pagination to this request
    func fetchPosts(
        withIDs ids: [PostID],
        onError: @escaping (RedditAPI.Error) -> Void
    ) -> Cancellable {
        api.posts(withIDs: ids) { response in
            Self.handleError(response, onError: onError) { listing in
                for kindedPost in listing.children {
                    self.store.posts[kindedPost.inner.id] = kindedPost.inner
                }
            }
        }
    }
    
    func fetchPost(
        withID id: PostID,
        onError: @escaping (RedditAPI.Error) -> Void
    ) -> Cancellable {
        api.post(withID: id) { response in
            Self.handleError(response, onError: onError) { post in
                self.store.posts[post.id] = post
            }
        }
    }
}
