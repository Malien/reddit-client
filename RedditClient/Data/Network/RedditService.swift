import Foundation

/// I'll be honest, it is a bit redundant. All of this logic can as well be inside of the `RedditRepository`
/// But it forced me to make `ApplicationStore` and to make it a class
struct RedditService {
    let store: ApplicationStore
    let api: RedditAPI
    
    init(store: ApplicationStore, baseURL: URL) {
        self.store = store
        self.api = RedditAPI(baseURL: baseURL)
    }
    
    private static func handleError<T>(_ result: Result<T, RedditAPI.Error>, onError: (RedditAPI.Error) -> Void, onSuccess: (T) -> Void) {
        switch result {
        case .success(let value):
            onSuccess(value)
        case .failure(let error):
            onError(error)
        }
    }
    
    private func paginationRequest<Request : RequestContainer>(
        of request: Request,
        limit: Int?,
        after: Request.Data.ID?,
        cachePath: WritableKeyPath<ApplicationStore, Cache<Request, PaginationContainer<Request.Data>>>,
        entityCachePath: WritableKeyPath<ApplicationStore, Cache<Request.Data.ID, Request.Data>>?,
        onError: @escaping (RedditAPI.Error) -> Void,
        fetch: @escaping (
            Request,
            Int?,
            Request.Data.ID?,
            @escaping (Result<RedditAPI.Listing<Request.Data>, RedditAPI.Error>) -> Void
        ) -> Cancellable
    ) -> Cancellable {
        // TODO: Figure out how to cancel all of these requests
        let cancellation = fetch(request, limit, after) { response in
            Self.handleError(response, onError: onError) { listing in
                let fetchMore = { (nextLimit: Int, nextAfter: Request.Data.ID?) -> Void in
                    _ = self.paginationRequest(
                        of: request,
                        limit: nextLimit,
                        after: nextAfter,
                        cachePath: cachePath,
                        entityCachePath: entityCachePath,
                        onError: onError,
                        fetch: fetch
                    )
                }
                if let entityCachePath = entityCachePath {
                    var entityCache = self.store[keyPath: entityCachePath]
                    for item in listing.children {
                        entityCache[item.inner.id] = item.inner
                    }
                }
                var cache = self.store[keyPath: cachePath]
                if var container = cache[request] {
                    container.items += listing.children.map { $0.inner }
                    container.doFetch = fetchMore
                    container.hasMore = listing.children.count == limit
                    cache[request] = container
                } else {
                    let items = listing.children.map { $0.inner }
                    let container = PaginationContainer(
                        items: items,
                        start: request.start,
                        hasMore: listing.children.count == limit,
                        doFetch: fetchMore
                    )
                    cache[request] = container
                }
            }
        }
        return cancellation
    }

    func fetchTopPosts(
        request: TopPostsRequest,
        limit: Int? = nil,
        after: Post.ID? = nil,
        onError: @escaping (RedditAPI.Error) -> Void
    ) -> Cancellable {
        paginationRequest(
            of: request,
            limit: limit,
            after: after,
            cachePath: \ApplicationStore.subredditTopPosts,
            entityCachePath: \ApplicationStore.posts,
            onError: onError
        ) { self.api.topPosts(from: $0.subreddit, limit: $1, after: $2, completionHandler: $3) }
    }
    
    // TODO: maybe add pagination to this request
    func fetchPosts(
        withIDs ids: [Post.ID],
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
        withID id: Post.ID,
        onError: @escaping (RedditAPI.Error) -> Void
    ) -> Cancellable {
        api.post(withID: id) { response in
            Self.handleError(response, onError: onError) { post in
                self.store.posts[post.id] = post
            }
        }
    }
    
    func fetchComments(
        request: CommentsRequest,
        limit: Int? = nil,
        after: Comment.ID? = nil,
        onError: @escaping (RedditAPI.Error) -> Void
    ) -> Cancellable {
        paginationRequest(
            of: request,
            limit: limit,
            after: after,
            cachePath: \ApplicationStore.postComments,
            entityCachePath: nil,
            onError: onError
        ) { self.api.comments(for: $0.post, limit: $1, after: $2, completionHandler: $3) }
    }
}
