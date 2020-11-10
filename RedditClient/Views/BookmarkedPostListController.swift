//
//  BookmarkedPostListController.swift
//  RedditClient
//
//  Created by Yaroslav on 10.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import UIKit

class BookmarkedPostListController : UITableViewController {
    static let reuseIndentifier = "postCell"
    
    private var posts: [Post] = []
    private var bookmarksViewModel: PostBookmarksViewModel! = nil
    
    private func onData(ofPosts posts: [Post]) {
        DispatchQueue.main.async {
            self.posts = posts
            self.tableView.reloadData()
        }
    }

    @objc
    private func navigateToBookmarks() {
        print("Nav")
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

        bookmarksViewModel = PostBookmarksViewModel(onBookmarked: { [weak self] (id, bookmarked) in
            guard let self = self else { return }
            self.onData(ofPosts: self.bookmarksViewModel.posts)
        })
        
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
        cell.populate(post: post)
        cell.populate(bookmarked: bookmarksViewModel.isBookmarked(postWithID: post.id))
        
        return cell
    }
}
