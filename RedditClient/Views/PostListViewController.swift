//
//  PostListViewController.swift
//  RedditClient
//
//  Created by Yaroslav on 08.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import UIKit

class PostListViewController: UITableViewController {
    
    var posts: PaginationContainer<Post>? = nil
    var viewModel: PostListViewModel! = nil
    
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
    
    @objc private func navigateToBookmarks() {
        print("Nav")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.reuseIndentifier)
        
        let bgView = UIView()
        bgView.backgroundColor = .background
        tableView.backgroundView = bgView
        self.tableView.rowHeight = UITableView.automaticDimension;
        self.tableView.estimatedRowHeight = 400;
        
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        
        navigationItem.title = "r/\(subreddit)"
        let bookmarksButton = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(navigateToBookmarks))
//        let bookmarksButton = UIBarButtonItem(image: ApplicationIcon.bookmarkOutlined, style: .plain, target: self, action: #selector(navigateToBookmarks))
        bookmarksButton.tintColor = .accent
//        bookmarksButton.image.resize
        navigationItem.rightBarButtonItem = bookmarksButton

        viewModel = PostListViewModel(
            subreddit: subreddit,
            onPosts: { [weak self] posts in
                print(posts.items.map { $0.title }.joined(separator: "\n"))
                print("\n")
                self?.onData(ofPosts: posts)
            }
        )
    }
    
    private func selected(post: Post) {
//        navigationController?.present(PostListViewController(style: .plain), animated: true, completion: nil)
//        navigationController?.pushViewController(PostListViewController(subreddit: "AskMen"), animated: true)
        navigationController?.pushViewController(DetailPostViewController(post: post), animated: true)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.reuseIndentifier, for: indexPath) as! PostTableViewCell
        
        let post = posts!.items[indexPath.row]
        cell.onComment = { [weak self] in
            guard let self = self else { return }
            self.selected(post: post)
        }
        cell.populate(post: post)

        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
