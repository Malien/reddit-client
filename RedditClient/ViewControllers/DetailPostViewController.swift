//
//  DetailPostViewController.swift
//  RedditClient
//
//  Created by Yaroslav on 09.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import UIKit

final class DetailPostViewController: UIViewController {
    
    let scrollView = UIScrollView().autolayouted()
    let postView: PostView
    let post: Post
    var bookmarksViewModel: PostBookmarksViewModel!
    let commentsViewController: CommentListViewController!

    init(post: Post) {
        self.post = post
        postView = PostView(post: post).autolayouted()
        commentsViewController = CommentListViewController(for: post.id)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { nil }
    
    func onData(ofPostBookmarked bookmarked: Bool) {
        DispatchQueue.main.async {
            self.postView.populate(bookmarked: bookmarked)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        navigationItem.title = "Post"
        
        // If there is no initialized view. Something is definetely wrong with SwiftUI
        let commentsView = commentsViewController.view!
        
        bookmarksViewModel = PostBookmarksViewModel( onBookmarked: { [weak self] (postID, bookmarked) in
            guard let self = self else { return }
            if postID == self.post.id {
                self.onData(ofPostBookmarked: bookmarked)
            }
        })
        
        postView.onShare = { [weak self] in
            guard let self = self else { return }
            let shareSheet = UIActivityViewController(activityItems: [self.post.url], applicationActivities: nil)
            self.present(shareSheet, animated: true, completion: nil)
        }
        postView.onDoubleTap = { [weak self] in
            guard let self = self else { return }
            self.bookmarksViewModel.bookmark(post: self.post)
        }
        postView.onBookmark = { [weak self] in
            guard let self = self else { return }
            self.bookmarksViewModel.toggle(bookmarkOfPost: self.post)
        }
        
        postView.populate(bookmarked: bookmarksViewModel.isBookmarked(postWithID: post.id))
        
        addChild(commentsViewController)
        
        commentsViewController.view.autolayouted()
        scrollView.addSubview(postView)
        scrollView.addSubview(commentsViewController.view)
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: postView, attribute: .leading , relatedBy: .equal, toItem: self.view      , attribute: .leading , multiplier: 1, constant: 0),
            NSLayoutConstraint(item: postView, attribute: .top     , relatedBy: .equal, toItem: self.scrollView, attribute: .top     , multiplier: 1, constant: 0),
            NSLayoutConstraint(item: postView, attribute: .trailing, relatedBy: .equal, toItem: self.view      , attribute: .trailing, multiplier: 1, constant: 0),

            NSLayoutConstraint(item: commentsView, attribute: .top     , relatedBy: .equal, toItem: postView  , attribute: .bottom  , multiplier: 1, constant: 0),
            NSLayoutConstraint(item: commentsView, attribute: .leading , relatedBy: .equal, toItem: view      , attribute: .leading , multiplier: 1, constant: 0),
            NSLayoutConstraint(item: commentsView, attribute: .trailing, relatedBy: .equal, toItem: view      , attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: commentsView, attribute: .bottom  , relatedBy: .equal, toItem: scrollView, attribute: .bottom  , multiplier: 1, constant: 0),
            
            NSLayoutConstraint(item: scrollView, attribute: .leading , relatedBy: .equal, toItem: view, attribute: .leading  , multiplier: 1, constant: 0),
            NSLayoutConstraint(item: scrollView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing , multiplier: 1, constant: 0),
            NSLayoutConstraint(item: scrollView, attribute: .top     , relatedBy: .equal, toItem: view, attribute: .topMargin, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: scrollView, attribute: .bottom  , relatedBy: .equal, toItem: view, attribute: .bottom   , multiplier: 1, constant: 0),
        ])
    }

}
