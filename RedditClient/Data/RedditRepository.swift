import Foundation

protocol SubscriptionHolder {
    mutating func unsubscribe()
}

final class RedditRepository {
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

        mutating func unsubscribe() {
            store[keyPath: cache].unsubscribe(from: request, subscription: subscription)
        }
    }

    /// Wish I could use `some SubsriptionHolder` as a return type, but it's available only from macOS 10.15 and iOS 13 and onwards
    func topPosts(
        from subreddit: String,
        limit: Int? = nil,
        after: PostID? = nil,
        force: Bool = false,
        dataStream: @escaping (Result<[Post], RedditAPI.Error>) -> Void
    ) -> Subscription<TopPostsRequest, [Post]> {
        let request = TopPostsRequest(subreddit: subreddit, limit: limit, after: after)
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

        if let items = store.subredditTopPosts[request] {
            dataStream(.success(items))
            if force {
                service.fetchTopPosts(request: request) { dataStream(.failure($0)) }
            }
        } else {
            service.fetchTopPosts(request: request) { dataStream(.failure($0)) }
        }

        return Subscription(
            request: request, subscription: subscription, store: store,
            cache: \ApplicationStore.subredditTopPosts)
    }

}
