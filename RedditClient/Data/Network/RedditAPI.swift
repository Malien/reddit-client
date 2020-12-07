import Foundation

extension URL {
    init(staticString string: StaticString) {
        guard let url = URL(string: "\(string)") else {
            preconditionFailure("Invalid static URL string: \(string)")
        }
        self = url
    }
}

extension RedditEntity where Self: Identifiable, Self.ID: EntityIdentifier, Self.ID.Entity == Self {
    static func paginate(components: inout URLComponents, limit: Int?, after: ID?) {
        var queryItems: [URLQueryItem] = []
        if let limit = limit {
            queryItems.append(URLQueryItem(name: "limit", value: limit.description))
        }
        if let after = after {
            queryItems.append(URLQueryItem(name: "after", value: after.fullname.description))
        }
        if components.queryItems != nil {
            components.queryItems!.append(contentsOf: queryItems)
        } else {
            components.queryItems = queryItems
        }
    }

}

protocol Cancellable {
    mutating func cancel()
}

extension Array: Cancellable where Element == Cancellable {
    mutating func cancel() { mutateEach { $0.cancel() } }
}

/// It can be a class, but this is basically URL wrapper with a few methods.
/// So copy-on-write semantics is ok here (cause again, for now it jsut contains a `baseURL` field)
struct RedditAPI {
    // MARK: Internal types

    /// I dunno what else reddit API might throw my way, other than 404
    enum ErrorResponse {
        case notFound(message: String)
        case other(code: Int, data: Data)

        static func error(from data: Data, response: HTTPURLResponse) -> ErrorResponse {

            let decoder = JSONDecoder()
            switch response.statusCode {
            case 404:
                struct NotFound: Codable {
                    let error: Int
                    let message: String
                }
                guard let errorStruct = try? decoder.decode(NotFound.self, from: data) else {
                    return .other(code: response.statusCode, data: data)
                }
                if (errorStruct.error != 404) {
                    return .other(code: errorStruct.error, data: data)
                }
                return .notFound(message: errorStruct.message)

            default:
                return .other(code: response.statusCode, data: data)
            }
        }
    }

    enum Error: Swift.Error {
        case invalidURL
        case requestError(Swift.Error? = nil)
        case invalidResponseKind(expected: String, got: String)
        case serverResponse(ErrorResponse)
    }

    // MARK: API Response types

    /// Wrapper for deserializing typed entities.
    /// This struct provides `{ kind: string, data: T }` (de)serialization wrapping
    /// Most of the times we know type of entities statically, when we make an api call.
    /// So we don't need (for now) dynamically resolve types of the inner objects.
    /// If we reuqest `/r/<subreddit>/top.json`, we know that we will recieve `Listing` of `Links`.
    /// If types are something else, this is not valid response.
    /// And for now there is no place where mutliple types might be encountered in the same list.
    struct Kinded<T: RedditEntity>: Encodable, Decodable {
        let inner: T
        init(_ inner: T) {
            self.inner = inner
        }

        enum CodingKeys: String, CodingKey {
            case kind
            case data
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(T.kind.description, forKey: .kind)
            try container.encode(inner, forKey: .data)
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let kind = try container.decode(String.self, forKey: .kind)
            if kind != T.kind {
                // TODO: use DecodingError
                throw Error.invalidResponseKind(expected: T.kind, got: kind)
            }
            let data = try container.decode(T.self, forKey: .data)
            self.inner = data
        }
    }

    /// Type reddit uses to provide pagination support
    struct Listing<T: RedditEntity>: RedditEntity {
        static var kind: String { "Listing" }

        let modhash: String
        let dist: Int?
        let after: String?
        let before: String?
        let children: [Kinded<T>]
    }

    // MARK: Actual implementation

    private let baseURL: URL

    init(baseURL: URL) {
        self.baseURL = baseURL
    }

    /// Provides means to cancell a reuqest task
    struct RequestCancellable : Cancellable {
        private let task: URLSessionDataTask

        init(_ task: URLSessionDataTask) {
            self.task = task
        }

        mutating func cancel() {
            task.cancel()
        }
    }
    
    struct DummyCancellable : Cancellable {
        mutating func cancel() { }
    }

    private typealias CompletionHandler<T> = (Result<T, Error>) -> Void

    /// Fetches resource (with a `GET` mehtod) specified in the `components` relative to `baseURL`.
    /// Upon completion `completionHandler` is called with the result of the operation.
    /// - Parameters:
    ///     - from: components which will be used to construct resource url
    ///     - completionHandler: escaping function which will be called asynchroniously with the result of the operation
    ///                          In case of successfull operation, handler will be called with `Result.success(T)`.
    ///                          Otherwise, in case of an error, handler will be called with `Result.failure(RedditAPI.Error)`
    /// - Returns: RedditAPI.Cancellable which can be used to cancel request
    /// - Note: If provided url component will result in invalid url, `completionHandler` will be called synchronously
    ///      with `Result.failure(RedditAPI.Error.invalidURL)` and fetch iteself will return `nil`
    private func fetch<T: Codable>(
        from components: URLComponents,
        completionHandler: @escaping CompletionHandler<T>
    ) -> Cancellable {
        var components = components
        components.queryItems = components.queryItems ?? []
        components.queryItems!.append(URLQueryItem(name: "raw_json", value: "1"))
        guard let url = components.url(relativeTo: baseURL) else {
            completionHandler(.failure(.invalidURL))
            return DummyCancellable()
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("utf-8", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, let _ = response else {
                completionHandler(.failure(.requestError(error)))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completionHandler(.failure(.requestError()))
                return
            }

            guard (100...400).contains(response.statusCode) else {
                completionHandler(
                    .failure(.serverResponse(ErrorResponse.error(from: data, response: response))))
                return
            }

            let decoder = JSONDecoder()
            do {
                let value = try decoder.decode(T.self, from: data)
                completionHandler(.success(value))
            } catch let invalidKind as Error {
                completionHandler(.failure(invalidKind))
            } catch let serialization {
                completionHandler(.failure(.requestError(serialization)))
            }
        }
        task.resume()
        return RequestCancellable(task)
    }

    /// Same as `RedditAPI.fetch(from:completionHandler:)`, except it transforms successfull value with `transform` function
    /// - Parameters:
    ///     - from: components which will be used to construct resource url
    ///     - completionHandler: escaping function which will be called asynchroniously with the result of the operation
    ///                          In case of successfull operation, handler will be called with `Result.success(T)`.
    ///                          Otherwise, in case of an error, handler will be called with `Result.failure(RedditAPI.Error)`
    ///     - transform: function which will be used to transform successfull result of an operation
    /// - Returns: RedditAPI.Cancellable which can be used to cancel request
    /// - Note: If provided url component will result in invalid url, `completionHandler` will be called synchronously
    ///         with `Result.failure(RedditAPI.Error.invalidURL)` and fetch iteself will return `nil`
    private func fetchMap<T: Codable, U>(
        from components: URLComponents,
        completionHandler: @escaping CompletionHandler<U>,
        transform: @escaping (T) -> U
    ) -> Cancellable {
        fetch(from: components) { (result: Result<T, Error>) in
            completionHandler(result.map(transform))
        }
    }
    
    // MARK: API Calls

    /// Fetch top posts from the subreddit specified.
    /// - Parameters:
    ///     - from: the name of the subreddit. Can be initialized with a simple string literal
    ///     - limit: maximum amount of entries to be fetched. Optional
    ///     - after: id of an entity used to set initial fetching point. Used for pagination. Optional
    ///     - completionHandler: function that will run asynchronously with the result of the operation.
    ///                          In case of successfull operation, handler will be called with `Result.success(Listing<Post>)`.
    ///                          Otherwise, in case of an error, handler will be called with `Result.failure(RedditAPI.Error)`
    /// - Returns: `Cancellable` which can be used to cancel request
    /// - Note: If provided url component will result in invalid url, `completionHandler` will be called synchronously
    ///         with `Result.failure(RedditAPI.Error.invalidURL)` and fetch iteself will return `nil`
    @discardableResult
    public func topPosts(
        from subreddit: Subreddit, limit: Int? = nil, after: Post.ID? = nil,
        completionHandler: @escaping (Result<Listing<Post>, Error>) -> Void
    ) -> Cancellable {
        var components = URLComponents()
        components.path = "/r/\(subreddit)/top.json"
        Post.paginate(components: &components, limit: limit, after: after)

        return fetchMap(from: components, completionHandler: completionHandler) {
            (result: Kinded<Listing<Post>>) in result.inner
        }
    }
    
    /// Fetch a single post with id specified
    /// - Parameters:
    ///     - withdID: id of a post to be retrieved
    ///     - completionHandler: function that will run asynchronously with the result of the operation.
    ///                          In case of successfull operation, handler will be called with `Result.success(Post)`.
    ///                          Otherwise, in case of an error, handler will be called with `Result.failure(RedditAPI.Error)`
    /// - Returns: `Cancellable` which can be used to cancel request
    /// - Note: If provided url component will result in invalid url, `completionHandler` will be called synchronously
    ///         with `Result.failure(RedditAPI.Error.invalidURL)` and fetch iteself will return `nil`
    @discardableResult
    public func post(withID id: Post.ID, completionHandler: @escaping (Result<Post, Error>) -> Void) -> Cancellable {
        var components = URLComponents()
        components.path = "/by_id/\(id.fullname).json"
        
        return fetch(from: components) { (result: Result<Kinded<Listing<Post>>, Error>) in
            let newRes: Result<Post, Error> = result.flatMap { kinded in
                if let post = kinded.inner.children.first {
                    return .success(post.inner)
                } else {
                    return .failure(.serverResponse(.notFound(message: "On request of post(withID: \(id)) empty listing returned")))
                }
            }
            completionHandler(newRes)
        }
    }
    
    /// Fetch top posts from the subreddit specified.
    /// - Parameters:
    ///     - withIDs: list of post ids to be retrieved
    ///     - limit: maximum amount of entries to be fetched. Optional
    ///     - after: id of an entity used to set initial fetching point. Used for pagination. Optional
    ///     - completionHandler: function that will run asynchronously with the result of the operation.
    ///                          In case of successfull operation, handler will be called with `Result.success(Listing<Post>)`.
    ///                          Otherwise, in case of an error, handler will be called with `Result.failure(RedditAPI.Error)`
    /// - Returns: `Cancellable` which can be used to cancel request
    /// - Note: If provided url component will result in invalid url, `completionHandler` will be called synchronously
    ///         with `Result.failure(RedditAPI.Error.invalidURL)` and fetch iteself will return `nil`
    @discardableResult
    public func posts(
        withIDs ids: [Post.ID],
        limit: Int? = nil,
        after: Post.ID? = nil,
        completionHandler: @escaping (Result<Listing<Post>, Error>) -> Void
    ) -> Cancellable {
        var components = URLComponents()
        let idsString = ids.map { $0.fullname.description }.joined(separator: ",")
        components.path = "/by_id/\(idsString).json"
        Post.paginate(components: &components, limit: limit, after: after)

        return fetchMap(from: components, completionHandler: completionHandler) {
            (result: Kinded<Listing<Post>>) in result.inner
        }
    }
    
    /// Fetch comments to the post in the subreddit specified.
    /// - Parameters:
    ///     - for: id of a post
    ///     - limit: maximum amount of entries to be fetched. Optional
    ///     - after: id of an entity used to set initial fetching point. Used for pagination. Optional
    ///     - completionHandler: function that will run asynchronously with the result of the operation.
    ///                          In case of successfull operation, handler will be called with `Result.success(Listing<Comment>)`.
    ///                          Otherwise, in case of an error, handler will be called with `Result.failure(RedditAPI.Error)`
    /// - Returns: `Cancellable` which can be used to cancel request
    /// - Note: If provided url component will result in invalid url, `completionHandler` will be called synchronously
    ///         with `Result.failure(RedditAPI.Error.invalidURL)` and fetch iteself will return `nil`
    @discardableResult
    public func comments(
        for postID: Post.ID,
        limit: Int? = nil,
        after: Comment.ID? = nil,
        completionHandler: @escaping (Result<Listing<Comment>, Error>) -> Void
    ) -> Cancellable {
        var components = URLComponents()
        components.path = "/comments/\(postID).json"
        components.queryItems = [
            URLQueryItem(name: "depth", value: "1"),
            URLQueryItem(name: "showmore", value: "0")
        ]
        Comment.paginate(components: &components, limit: limit, after: after)
        
        return fetchMap(from: components, completionHandler: completionHandler) {
            (result: CodableTuple<Kinded<Listing<Post>>, Kinded<Listing<Comment>>>) in result.second.inner
        }
    }

}
