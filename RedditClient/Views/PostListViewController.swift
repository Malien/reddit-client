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

    private func onData(ofPosts posts: PaginationContainer<Post>) {
        DispatchQueue.main.async {
            self.posts = posts
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.reuseIndentifier)
        
        tableView.autolayouted()
        self.tableView.rowHeight = UITableView.automaticDimension;
        self.tableView.estimatedRowHeight = 400;
        
        tableView.allowsSelection = false
        tableView.separatorStyle = .none

        viewModel = PostListViewModel(
            subreddit: "ios",
            onPosts: { [weak self] posts in
                print(posts.items.map { $0.title }.joined(separator: "\n"))
                print("\n")
                self?.onData(ofPosts: posts)
            }
        )
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
        
        cell.populate(post: posts!.items[indexPath.row])

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
