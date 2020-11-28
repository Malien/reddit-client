//
//  CommentsList.swift
//  RedditClient
//
//  Created by Yaroslav on 28.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import SwiftUI

struct CommentsList: View {
    @ObservedObject var viewModel: CommentsViewModel
    var body: some View {
        List {
            Text("No fancy application background for you! At least in dark mode. I'm to lazy to upgrade to Xcode 12 and use LazyVStack. SwiftUI's List view is completely unstylable")
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

#if DEBUG

struct CommentsList_Previews: PreviewProvider {
    static let comments = Array.init(repeating: CommentView_Previews.comment, count: 5)
    
    static var previews: some View {
        CommentsList(viewModel: CommentsViewModel(for: PostID(string: "jrbomi"), batchSize: 10))
            .previewDisplayName("Comment list")
    }
}

#endif
