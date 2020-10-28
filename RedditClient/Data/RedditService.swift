import Foundation

/// I'll be honest, it is a bit redundant. All of this logic can as well be inside of the `RedditRepository`
/// But it forced me to make `ApplicationStore` and to make it a class
struct RedditService {
    let store: ApplicationStore
    let api = RedditAPI()

    func fetchTopPosts(request: TopPostsRequest, onError: @escaping (RedditAPI.Error) -> Void) {
        api.topPosts(from: request.subreddit, limit: request.limit, after: request.after) {
            response in
            switch response {
            case .success(let listing):
                self.store.subredditTopPosts[request] = listing.children.map { $0.inner }
            case .failure(let error):
                onError(error)
            }
        }
    }
}
