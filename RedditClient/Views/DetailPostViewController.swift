//
//  DetailPostViewController.swift
//  RedditClient
//
//  Created by Yaroslav on 09.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import UIKit

class DetailPostViewController: UIViewController {
    
    let scrollView = UIScrollView().autolayouted()
    let postView: PostView

    init(post: Post) {
        postView = PostView(post: post).autolayouted()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        navigationItem.title = "Post"
        
        scrollView.addSubview(postView)
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: postView, attribute: .leading , relatedBy: .equal, toItem: self.view      , attribute: .leading , multiplier: 1, constant: 0),
            NSLayoutConstraint(item: postView, attribute: .top     , relatedBy: .equal, toItem: self.scrollView, attribute: .top     , multiplier: 1, constant: 0),
            NSLayoutConstraint(item: postView, attribute: .trailing, relatedBy: .equal, toItem: self.view      , attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: postView, attribute: .bottom  , relatedBy: .equal, toItem: self.scrollView, attribute: .bottom  , multiplier: 1, constant: 0),
            
            NSLayoutConstraint(item: scrollView, attribute: .leading , relatedBy: .equal, toItem: view, attribute: .leading  , multiplier: 1, constant: 0),
            NSLayoutConstraint(item: scrollView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing , multiplier: 1, constant: 0),
            NSLayoutConstraint(item: scrollView, attribute: .top     , relatedBy: .equal, toItem: view, attribute: .topMargin, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: scrollView, attribute: .bottom  , relatedBy: .equal, toItem: view, attribute: .bottom   , multiplier: 1, constant: 0)
        ])
    }

}
