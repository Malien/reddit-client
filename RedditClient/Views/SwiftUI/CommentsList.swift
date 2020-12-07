//
//  CommentsList.swift
//  RedditClient
//
//  Created by Yaroslav on 28.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import SwiftUI

struct CommentsList<ViewModel: CommentsViewModel>: View {
    @ObservedObject var viewModel: ViewModel
    var body: some View {
        LazyVStack {
            ForEach(viewModel.comments.indices, id: \.self) { idx in
                ListLink(
                    destination: CommentDetailView(comment: self.viewModel.comments[idx])
                ) { CommentView(comment: self.viewModel.comments[idx]) }
//                .onAppear jjjjV
//                    if idx >= self.viewModel.comments.endIndex - 1 {
//                        print("Sup")
//                        self.viewModel.fetchMore()
//                    }
//                }
            }
        }
        .background(Color(UIColor.background))
    }
}

struct CommentsList_Previews: PreviewProvider {
    class DummyCommentsViewModel: CommentsViewModel {
        var comments = Array.init(repeating: CommentView_Previews.comment, count: 5)
        func fetchMore() { }
    }
    
    static var previews: some View {
        CommentsList(viewModel: DummyCommentsViewModel())
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Comment list")
    }
}
