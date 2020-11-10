import Foundation

struct TopPostsRequest: Hashable, Codable {
    let subreddit: Subreddit
    let start: PostID?
}

class CompoundCancellable: Cancellable {
    var cancellations: [Cancellable] = []
    
    func add(cancellation: Cancellable) {
        cancellations.append(cancellation)
    }
    
    func cancel() {
        cancellations.mutateEach { $0.cancel() }
    }
}

/// I'll be honest, it is a bit redundant. All of this logic can as well be inside of the `RedditRepository`
/// But it forced me to make `ApplicationStore` and to make it a class
struct RedditService {
    let store: ApplicationStore
    let api = RedditAPI()

    func fetchTopPosts(
        request: TopPostsRequest,
        limit: Int? = nil,
        after: PostID? = nil,
        onError: @escaping (RedditAPI.Error) -> Void
    ) -> Cancellable {
        let cancellable = CompoundCancellable()
        let cancellation = api.topPosts(from: request.subreddit, limit: limit, after: after) { response in
            switch response {
            case .success(let listing):
                let fetchMore = { (limit: Int, after: Post.Key?) -> Void in
                    let cancellation = self.fetchTopPosts(request: request, limit: limit, after: after) { error in
                        onError(error)
                    }
                    cancellable.add(cancellation: cancellation)
                }
                #if CACHE_POSTS
                for post in listing.children {
                    self.store.posts[post.inner.id] = post.inner
                }
                #endif
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
            case .failure(let error):
                onError(error)
            }
        }
        cancellable.add(cancellation: cancellation)
        return cancellable
    }
}
