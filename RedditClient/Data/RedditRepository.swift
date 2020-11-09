import Foundation

protocol SubscriptionHolder {
    mutating func unsubscribe()
}

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

    struct Subscription<Key, Value>: SubscriptionHolder where Key: Hashable {
        let request: Key
        let subscription: Cache<Key, Value>.SubscriptionID
        private(set) var store: ApplicationStore
        let cache: WritableKeyPath<ApplicationStore, Cache<Key, Value>>
        private(set) var cancellations: [Cancellable]

        mutating func unsubscribe() {
            store[keyPath: cache].unsubscribe(from: request, subscription: subscription)
            cancellations.mutateEach { $0.cancel() }
        }
    }

    /// Wish I could use `some SubsriptionHolder` as a return type, but it's available only from macOS 10.15 and iOS 13 and onwards
//    func topPosts(
//        from subreddit: String,
//        limit: Int? = nil,
//        after: PostID? = nil,
//        force: Bool = false,
//        dataStream: @escaping (Result<[Post], RedditAPI.Error>) -> Void
//    ) -> Subscription<TopPostsRequest, [Post]> {
//        let request = TopPostsRequest(subreddit: subreddit, limit: limit, after: after)
//        let subscription = store.subredditTopPosts.subscribe(to: request) { event in
//            switch event {
//            case .added(let posts):
//                dataStream(.success(posts))
//            case .updated(let posts, _):
//                dataStream(.success(posts))
//            default:
//                break
//            }
//        }
//
//        var cancellations: [Cancellable] = []
//
//        if let items = store.subredditTopPosts[request] {
//            dataStream(.success(items))
//            if force {
//                cancellations.append(service.fetchTopPosts(request: request) { dataStream(.failure($0)) })
//            }
//        } else {
//            cancellations.append(service.fetchTopPosts(request: request) { dataStream(.failure($0)) })
//        }
//
//        return Subscription(
//            request: request, subscription: subscription, store: store,
//            cache: \ApplicationStore.subredditTopPosts, cancellations: cancellations)
//    }
    
    func topPosts(
        from subreddit: String,
        limit: Int,
        after: PostID? = nil,
        force: Bool = false,
        dataStream: @escaping (Result<PaginationContainer<Post>, RedditAPI.Error>) -> Void
    ) -> SubscriptionHolder {
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
            cache: \ApplicationStore.subredditTopPosts, cancellations: cancellations)
    }

}
