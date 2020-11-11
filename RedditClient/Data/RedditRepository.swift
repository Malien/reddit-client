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

struct RedditRepository {
    let service: RedditService
    let store: ApplicationStore

    init(store: ApplicationStore) {
        self.store = store
        self.service = RedditService(store: store)
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
    
    func topPosts(
        from subreddit: Subreddit,
        limit: Int,
        after: PostID? = nil,
        force: Bool = false,
        dataStream: @escaping (Result<PaginationContainer<Post>, RedditAPI.Error>) -> Void
    ) -> Cancellable {
        let request = TopPostsRequest(subreddit: subreddit, start: after)
        let subscription = store.subredditTopPosts.subscribe(to: request) { event in
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
        
        let makeRequest = {
            let cancellation = self.service.fetchTopPosts(request: request, limit: limit, after: after) {
                dataStream(.failure($0))
            }
            cancellations.append(cancellation)
        }
        
        if let items = store.subredditTopPosts[request] {
            dataStream(.success(items))
            if force {
                makeRequest()
            }
        } else {
            makeRequest()
        }
        
        return Subscription(
            request: request, subscription: subscription, store: store,
            cache: \ApplicationStore.subredditTopPosts, cancellation: cancellations)
    }

//    func posts(
//        withIDs ids: [PostID],
//        limit: Int? = nil,
//        after: PostID? = nil,
//        force: Bool = false,
//        dataStream: @escaping (Result<[Post], RedditAPI.Error>) -> Void
//    ) -> SubscriptionHolder {
//        let request = PostsRequest(ids: ids)
//        let subscription = store.posts.subscribe { event in
//            switch event {
//            case .updated(let key, let value):
//                dataStream
//            }
//        }
//
//        var cancellations: [Cancellable] = []
//
//        let makeRequest = {
//            let cancellation = self.service.fetchTopPosts(request: request, limit: limit, after: after) {
//                dataStream(.failure($0))
//            }
//            cancellations.append(cancellation)
//        }
//
//        if let items = store.subredditTopPosts[request] {
//            dataStream(.success(items))
//            if force {
//                makeRequest()
//            }
//        } else {
//            makeRequest()
//        }
//
//        return Subscription(
//            request: request, subscription: subscription, store: store,
//            cache: \ApplicationStore.subredditTopPosts, cancellations: cancellations)
//
//    }
    
    func post(
        withID id: PostID,
        force: Bool = false,
        dataStream: @escaping (Result<Post, RedditAPI.Error>) -> Void
    ) -> Cancellable {
        let subscription = store.posts.subscribe(to: id) { event in
            switch event {
            case .added(let post):
                dataStream(.success(post))
            case .updated(let post, _):
                dataStream(.success(post))
            default:
                break
            }
        }
        
        var cancellations: [Cancellable] = []
        
        let makeRequest = {
            let cancellation = self.service.fetchPost(withID: id) {
                dataStream(.failure($0))
            }
            cancellations.append(cancellation)
        }
        
        if let post = store.posts[id] {
            dataStream(.success(post))
            if force {
                makeRequest()
            }
        } else {
            makeRequest()
        }
        
        return Subscription(request: id, subscription: subscription, store: store, cache: \ApplicationStore.posts, cancellation: cancellations)
    }
}
