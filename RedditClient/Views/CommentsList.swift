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
        List {
            Text("No fancy application background for you! At least in dark mode. I'm too lazy to upgrade to Xcode 12 and use LazyVStack (no pun intended). SwiftUI's List view is completely unstylable")
                .font(.system(size: 14))
                .foregroundColor(Color(UIColor.subtext))
            ForEach(viewModel.comments.indices, id: \.self) { idx in
                NavigationLink(
                    destination: CommentDetailView(comment: self.viewModel.comments[idx])
                ) {
                    CommentView(comment: self.viewModel.comments[idx])
                }
//                .onAppear {
//                    if idx >= self.viewModel.comments.endIndex - 1 {
//                        print("Sup")
//                        self.viewModel.fetchMore()
//                    }
//                }
            }
        }
    }
}

struct CommentsList_Previews: PreviewProvider {
    class DummyCommentsViewModel: CommentsViewModel {
        var comments = Array.init(repeating: CommentView_Previews.comment, count: 5)
        func fetchMore() { }
    }
    
    static var previews: some View {
        CommentsList(viewModel: DummyCommentsViewModel())
            .previewDisplayName("Comment list")
    }
}
