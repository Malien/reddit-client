//
//  PostListViewController.swift
//  RedditClient
//
//  Created by Yaroslav on 08.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import UIKit

class PostListViewController: UITableViewController {
    
    static let reuseIndentifier = "postCell"
    
    private var posts: PaginationContainer<Post>? = nil
    private var postListViewModel: PostListViewModel! = nil
    private var bookmarksViewModel: PostBookmarksViewModel! = nil
    
    let subreddit: Subreddit
    
    init(subreddit: Subreddit) {
        self.subreddit = subreddit
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) { nil }
    
    private func onData(ofPosts posts: PaginationContainer<Post>) {
        DispatchQueue.main.async {
            self.posts = posts
            self.tableView.reloadData()
        }
    }
    
    private func onData(ofBookmarkedPostWithID id: PostID, bookmarked: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let idx = self.posts?.items.firstIndex { $0.id == id }
            guard idx != nil else { return }
            let indexPath = IndexPath(row: idx!, section: 0)
//            self.tableView.reloadRows(at: [indexPath], with: .automatic)
            let cell = self.tableView.cellForRow(at: indexPath) as? PostTableViewCell
            cell?.populate(bookmarked: bookmarked)
        }
    }
    
    @objc
    private func navigateToBookmarks() {
        navigationController?.pushViewController(BookmarkedPostListController(), animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(PostTableViewCell.self, forCellReuseIdentifier: Self.reuseIndentifier)
        
        let bgView = UIView()
        bgView.backgroundColor = .background
        tableView.backgroundView = bgView
        self.tableView.rowHeight = UITableView.automaticDimension;
        self.tableView.estimatedRowHeight = 400;
        
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        
        navigationItem.title = "r/\(subreddit)"
        let bookmarksButton = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(navigateToBookmarks))
        bookmarksButton.tintColor = .accent
        navigationItem.rightBarButtonItem = bookmarksButton
        
        bookmarksViewModel = PostBookmarksViewModel(onBookmarked: { [weak self] (id, bookmarked) in
            self?.onData(ofBookmarkedPostWithID: id, bookmarked: bookmarked)
        })

        postListViewModel = PostListViewModel(
            subreddit: subreddit,
            onPosts: { [weak self] posts in
                self?.onData(ofPosts: posts)
            }
        )
    }
    
    private func selected(commentsOfPost post: Post) {
        navigationController?.pushViewController(DetailPostViewController(post: post), animated: true)
    }
    
    private func on(_ post: Post, bookmarkStatus: Bool) {
        bookmarksViewModel.bookmark(post: post)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts?.items.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let posts = posts, posts.hasMore && indexPath.row > posts.items.count - 2 {
            posts.fetchMore(count: 5)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.reuseIndentifier, for: indexPath) as! PostTableViewCell
        
        let post = posts!.items[indexPath.row]
        cell.onComment = { [weak self] in
            self?.selected(commentsOfPost: post)
        }
        cell.onBookmark = { [weak self] in
            self?.bookmarksViewModel.toggle(bookmarkOfPost: post)
        }
        cell.populate(post: post)
        cell.populate(bookmarked: bookmarksViewModel.isBookmarked(postWithID: post.id))

        return cell
    }

}
