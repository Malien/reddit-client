//
//  CommentView.swift
//  RedditClient
//
//  Created by Yaroslav on 28.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import SwiftUI

struct CommentView: View {
    var comment: Comment
    
    var votes : some View {
        if comment.score > 0 {
            return Text("+\(comment.score)")
                .foregroundColor(.init(UIColor.upvote))
        } else if comment.score < 0 {
            return Text(comment.score.description)
                .foregroundColor(.init(UIColor.downvote))
        } else {
            return Text("0")
        }
    }
    
    var body: some View {
        HStack(alignment: .top) {
            votes
                .frame(minWidth: 35)
                .padding(.top, 8)
            VStack(alignment: .leading) {
                HStack {
                    Text(comment.author ?? "promotional")
                        .foregroundColor(.init(UIColor.accent))
                    Text("•")
                    Text(comment.userReadableTimeDiff)
                        .foregroundColor(.init(UIColor.subtext))
                }
                .font(.system(size: 14))
                Text(comment.body)
                    .foregroundColor(.init(UIColor.text))
            }
        }
    }
}

struct CommentView_Previews: PreviewProvider {
    static let comment = Comment(
        id: CommentID(string: ""),
        name: Fullname(id: CommentID(string: "")),
        ups: 34,
        downs: 3,
        score: 45,
        likes: .none,
        createdEpoch: 0,
        createdEpochUTC: 0,
        author: "user",
        authorFullname: "",
        permalink: "",
        body: "This is such a nice comment"
    )

    static var previews: some View {
        Group {
            CommentView(comment: comment)
                .padding()
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Single comment")
            CommentView(comment: comment)
                .padding()
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Single comment in dark mode")
                .background(Color(UIColor.background))
                .environment(\.colorScheme, .dark)
        }
    }
}
