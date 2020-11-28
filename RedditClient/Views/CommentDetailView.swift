//
//  CommentDetailView.swift
//  RedditClient
//
//  Created by Yaroslav on 28.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import SwiftUI

struct CommentDetailView: View {
    var comment: Comment
    
    func handleShare() {
        let shareSheet = UIActivityViewController(activityItems: [comment.url], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(shareSheet, animated: true)
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.background)
                .edgesIgnoringSafeArea(.all)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            VStack(spacing: 12) {
                HStack {
                    CommentView(comment: comment)
                    Spacer()
                }
                Button(action: handleShare) {
                    Text("Share")
                        .padding(.vertical, 8)
                        .padding(.horizontal, 32)
                }
                .foregroundColor(.white)
                .background(Color(UIColor.accent))
                .cornerRadius(10)
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.top, 30)
        }
        .navigationBarTitle("Comment")
    }
}

struct CommentDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CommentDetailView(comment: CommentView_Previews.comment)
    }
}
