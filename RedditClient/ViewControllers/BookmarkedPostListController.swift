//
//  BookmarkedPostListController.swift
//  RedditClient
//
//  Created by Yaroslav on 10.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import UIKit

final class BookmarkedPostListController : UITableViewController, UISearchResultsUpdating {
    static let reuseIndentifier = "postCell"
    
    private var posts: [Post] = []
    private var bookmarksViewModel: PostBookmarksViewModel!
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var updateSearchTask: DispatchWorkItem? = nil
    
    private func onData(ofPosts posts: [Post]) {
        // TBH I preemptively set [weak self] cause who knows when async fill fire (even on main thread)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.posts = posts
            self.tableView.reloadData()
        }
    }
    
    private func onData(ofUpdatedPost post: Post) {
        DispatchQueue.main.async { [weak self] in
            // TODO: reload only one cell
            guard let self = self else { return }
            self.posts = self.bookmarksViewModel.posts
            self.tableView.reloadData()
        }
    }
    
    private func onDataOfSearch() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.posts = self.bookmarksViewModel.posts
            self.tableView.reloadData()
        }
    }
    
    static let searchUpdateTimeout = DispatchTimeInterval.milliseconds(600)
    func updateSearchResults(for searchController: UISearchController) {
        var text = searchController.searchBar.text?.lowercased().trimmingCharacters(in: .whitespaces)
        if text == "" {
            text = nil
        }

        updateSearchTask?.cancel()
        let task = DispatchWorkItem { [weak self] in
            self?.bookmarksViewModel.filter = text
        }
        updateSearchTask = task
        ApplicationServices.dataQueue.asyncAfter(deadline: DispatchTime.now() + Self.searchUpdateTimeout, execute: task)
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
        
        navigationItem.title = "Bookmarks"
        navigationItem.searchController = searchController
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false

        bookmarksViewModel = PostBookmarksViewModel(
            onBookmarked: { [weak self] (id, bookmarked) in
                guard let self = self else { return }
                self.onData(ofPosts: self.bookmarksViewModel.posts)
            },
            onUpdate: { [weak self] (post) in
                self?.onData(ofUpdatedPost: post)
            },
            onSearch: { [weak self] in
                self?.onDataOfSearch()
            }
        )
        bookmarksViewModel.refreshBookmarks()
        
        onData(ofPosts: bookmarksViewModel.posts)
        
    }
    
    private func selected(commentsOfPost post: Post) {
        navigationController?.pushViewController(DetailPostViewController(post: post), animated: true)
    }
    
    private func on(_ post: Post, bookmarkStatus: Bool) {
        bookmarksViewModel.bookmark(post: post)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { posts.count }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.reuseIndentifier, for: indexPath) as! PostTableViewCell
        
        let post = posts[indexPath.row]
        cell.onComment = { [weak self] in
            self?.selected(commentsOfPost: post)
        }
        cell.onBookmark = { [weak self] in
            self?.bookmarksViewModel.toggle(bookmarkOfPost: post)
        }
        cell.onDoubleTap = { [weak self] in
            self?.bookmarksViewModel.bookmark(post: post)
        }
        cell.populate(post: post)
        cell.populate(bookmarked: bookmarksViewModel.isBookmarked(postWithID: post.id))
        
        return cell
    }
}
