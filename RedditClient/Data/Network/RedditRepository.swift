import Foundation

extension Array {
    mutating func mutateEach(by transform: (inout Element) throws -> Void) rethrows {
        self = try map { el in
            var el = el
            try transform(&el)
            return el
        }
     }
}

class RedditRepository {
    let service: RedditService
    var store: ApplicationStore

    init(store: ApplicationStore, baseURL: URL) {
        self.store = store
        self.service = RedditService(store: store, baseURL: baseURL)
    }

    struct Subscription<Key, Value>: Cancellable where Key: Hashable {
        let request: Key
        let subscription: SubscriptionID<Cache<Key, Value>>
        private(set) var store: ApplicationStore
        let cache: WritableKeyPath<ApplicationStore, Cache<Key, Value>>
        private(set) var cancellation: Cancellable

        mutating func cancel() {
            store[keyPath: cache].unsubscribe(from: request, subscription: subscription)
            cancellation.cancel()
        }
    }
    
    private func request<Request, Response>(
        request: Request,
        fetchCondition: (Response) -> Bool,
        dataStream: @escaping(Result<Response, RedditAPI.Error>) -> Void,
        cachePath: WritableKeyPath<ApplicationStore, Cache<Request, Response>>,
        fetch: (Request, @escaping (RedditAPI.Error) -> Void) -> Cancellable
    ) -> Cancellable {
        let subscription = store[keyPath: cachePath].subscribe(to: request) { event in
            switch event {
            case .added(let posts):
                dataStream(.success(posts))
            case .updated(let posts, _):
                dataStream(.success(posts))
            default:
                break
            }
        }
        
        var cancellations: [Cancellable] = []
        
        func makeRequest() {
            let cancellation = fetch(request) {
                dataStream(.failure($0))
            }
            cancellations.append(cancellation)
        }
        
        if let items = store[keyPath: cachePath][request] {
            dataStream(.success(items))
            if fetchCondition(items) {
                makeRequest()
            }
        } else {
            makeRequest()
        }
        
        return Subscription(
            request: request, subscription: subscription, store: store,
            cache: cachePath, cancellation: cancellations)
    }
    
    private func singleRequest<Request, Response>(
        request: Request,
        force: Bool,
        dataStream: @escaping(Result<Response, RedditAPI.Error>) -> Void,
        cachePath: WritableKeyPath<ApplicationStore, Cache<Request, Response>>,
        fetch: (Request, @escaping (RedditAPI.Error) -> Void) -> Cancellable
    ) -> Cancellable {
        self.request(
            request: request,
            fetchCondition: { _ in force },
            dataStream: dataStream,
            cachePath: cachePath,
            fetch: fetch
        )
    }
    
    private func paginatedRequest<Request: RequestContainer>(
        request: Request,
        limit: Int,
        after: Request.Data.ID?,
        force: Bool,
        dataStream: @escaping(Result<PaginationContainer<Request.Data>, RedditAPI.Error>) -> Void,
        cachePath: WritableKeyPath<ApplicationStore, Cache<Request, PaginationContainer<Request.Data>>>,
        fetch: (Request, Int?, Request.Data.ID?, @escaping (RedditAPI.Error) -> Void) -> Cancellable
    ) -> Cancellable {
        self.request(
            request: request,
            fetchCondition: { force || $0.items.count > 0 },
            dataStream: dataStream,
            cachePath: cachePath,
            fetch: { fetch($0, limit, after, $1) }
        )
    }
    
    // MARK: Actual requests

    func topPosts(
        from subreddit: Subreddit,
        limit: Int,
        after: Post.ID? = nil,
        force: Bool = false,
        dataStream: @escaping (Result<PaginationContainer<Post>, RedditAPI.Error>) -> Void
    ) -> Cancellable {
        paginatedRequest(
            request: TopPostsRequest(subreddit: subreddit, start: after),
            limit: limit,
            after: after,
            force: force,
            dataStream: dataStream,
            cachePath: \ApplicationStore.subredditTopPosts,
            fetch: service.fetchTopPosts(request:limit:after:onError:)
        )
    }
    
    func comments(
        for postID: Post.ID,
        limit: Int,
        after: Comment.ID? = nil,
        force: Bool = false,
        dataStream: @escaping (Result<PaginationContainer<Comment>, RedditAPI.Error>) -> Void
    ) -> Cancellable {
        paginatedRequest(
            request: CommentsRequest(post: postID, start: after),
            limit: limit,
            after: after,
            force: force,
            dataStream: dataStream,
            cachePath: \ApplicationStore.postComments,
            fetch: service.fetchComments(request:limit:after:onError:)
        )
    }

    func post(
        withID id: Post.ID,
        force: Bool = false,
        dataStream: @escaping (Result<Post, RedditAPI.Error>) -> Void
    ) -> Cancellable {
        singleRequest(
            request: id,
            force: force,
            dataStream: dataStream,
            cachePath: \ApplicationStore.posts,
            fetch: service.fetchPost(withID:onError:)
        )
    }
}
