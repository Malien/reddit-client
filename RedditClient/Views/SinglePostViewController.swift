//
//  ViewController.swift
//  RedditClient
//
//  Created by Yaroslav on 28.10.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import UIKit

class SinglePostViewController: UIViewController {
    
    @ThreadSafe(queueTarget: DispatchQueue.main)
    var postView: PostView? = nil
    var subscription: SubscriptionHolder?
    let scroll = UIScrollView().autolayouted()
    var bookmarked = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.autolayouted()
        view.backgroundColor = .background
        
        view.addSubview(scroll)

        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: scroll, attribute: .leading , relatedBy: .equal, toItem: view, attribute: .leading , multiplier: 1, constant: 0),
            NSLayoutConstraint(item: scroll, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: scroll, attribute: .top     , relatedBy: .equal, toItem: view, attribute: .top     , multiplier: 1, constant: 20),
            NSLayoutConstraint(item: scroll, attribute: .bottom  , relatedBy: .equal, toItem: view, attribute: .bottom  , multiplier: 1, constant: 0)
        ])

        subscription = reddit.topPosts(from: "ios", limit: 1) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let posts):
                if let post = posts.first {
                    self.onData(ofPost: post)
                } else {
                    print("No posts")
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func onData(ofBookmark bookmark: Bool) {
        $postView.mutate { [weak self] postView in
            guard let self = self else { return }
            self.bookmarked = bookmark
            guard let postView = postView else { return }
            postView.populate(bookmarked: bookmark)
        }
    }
    
    private func onData(ofPost post: Post) {
        $postView.mutate { [weak self] postView in
            guard let self = self else { return }
            if let postView = postView {
                postView.populate(post: post)
            } else {
                let newPostView = PostView(post: post, bookmarked: self.bookmarked, onBookmark: { [weak self] in
                    guard let self = self else { return }
                    self.onData(ofBookmark: !self.bookmarked)
                })
                self.scroll.addSubview(newPostView)
                
                newPostView.autolayouted()
                NSLayoutConstraint.activate([
                    NSLayoutConstraint(item: newPostView, attribute: .leading , relatedBy: .equal, toItem: self.view  , attribute: .leading , multiplier: 1, constant: 0),
                    NSLayoutConstraint(item: newPostView, attribute: .top     , relatedBy: .equal, toItem: self.scroll, attribute: .top     , multiplier: 1, constant: 0),
                    NSLayoutConstraint(item: newPostView, attribute: .trailing, relatedBy: .equal, toItem: self.view  , attribute: .trailing, multiplier: 1, constant: 0),
                    NSLayoutConstraint(item: newPostView, attribute: .bottom  , relatedBy: .equal, toItem: self.scroll, attribute: .bottom  , multiplier: 1, constant: 0)
                ])
                self.postView = newPostView
            }
            
        }
    }
    
    deinit {
        subscription?.unsubscribe()
    }

}
