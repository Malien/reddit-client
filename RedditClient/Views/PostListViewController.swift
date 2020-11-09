//
//  PostListViewController.swift
//  RedditClient
//
//  Created by Yaroslav on 08.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import UIKit

class PostListViewController: UITableViewController {
    
    var post: Post? = nil
    var viewModel: SinglePostViewModel! = nil

    private func onData(ofPost post: Post) {
        DispatchQueue.main.async {
            self.post = post
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.reuseIndentifier)
        
        tableView.autolayouted()
        self.tableView.rowHeight = UITableView.automaticDimension;
        self.tableView.estimatedRowHeight = 400;
        
        viewModel = SinglePostViewModel(
            subreddit: "ios",
            onPost: { [weak self] post in
                guard let self = self else { return }
                self.onData(ofPost: post)
            },
            onBookmark: { _ in }
        )
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        post == nil ? 0 : 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.reuseIndentifier, for: indexPath) as! PostTableViewCell
        
        cell.autolayouted()
        
        cell.populate(post: post!)

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
