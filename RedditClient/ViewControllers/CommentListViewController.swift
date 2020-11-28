//
//  CommentListViewController.swift
//  RedditClient
//
//  Created by Yaroslav on 28.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import UIKit
import SwiftUI

class CommentListViewController: UIHostingController<CommentsList<CommentsViewModelImpl>> {
    let viewModel: CommentsViewModelImpl
    
    init(for postID: PostID, batchSize: Int = 10) {
        self.viewModel = CommentsViewModelImpl(for: postID, batchSize: batchSize)
        super.init(rootView: CommentsList(viewModel: self.viewModel))
    }
    required init?(coder aDecoder: NSCoder) { nil }
    
}
