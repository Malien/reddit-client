//
//  ViewController.swift
//  RedditClient
//
//  Created by Yaroslav on 28.10.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import UIKit

final class SinglePostViewController: UIViewController {
    
    @ThreadSafe(queueTarget: DispatchQueue.main)
    var postView: PostView? = nil
    let scroll = UIScrollView().autolayouted()

    var viewModel: SinglePostViewModel!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.autolayouted()
        view.backgroundColor = .background
        
        view.addSubview(scroll)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: scroll, attribute: .leading , relatedBy: .equal, toItem: view, attribute: .leading  , multiplier: 1, constant: 0),
            NSLayoutConstraint(item: scroll, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing , multiplier: 1, constant: 0),
            NSLayoutConstraint(item: scroll, attribute: .top     , relatedBy: .equal, toItem: view, attribute: .topMargin, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: scroll, attribute: .bottom  , relatedBy: .equal, toItem: view, attribute: .bottom   , multiplier: 1, constant: 0)
        ])

        viewModel = SinglePostViewModel(subreddit: "ios",
            onPost: { [weak self] post in
                self?.onData(ofPost: post)
            },
            onBookmark: { [weak self] bookmark in
                self?.onData(ofBookmark: bookmark)
            }
        )
    }
    
    private func onData(ofBookmark bookmark: Bool) {
        $postView.mutate { [bookmark] postView in
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
                let newPostView = PostView(post: post, bookmarked: self.viewModel.bookmarked, onBookmark: { [weak self] in
                    guard let self = self else { return }
                    self.viewModel.bookmarked.toggle()
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

}
