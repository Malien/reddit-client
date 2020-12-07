//
//  ListSeparatorView.swift
//  RedditClient
//
//  Created by Yaroslav on 07.12.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import SwiftUI

struct ListSeparator: View {
    let leftMargin: CGFloat = 35 + 24
    let rightMargin: CGFloat = 24
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            Path { path in
                path.move(to: CGPoint(x: leftMargin, y: height / 2))
                path.addLine(to: CGPoint(x: width - rightMargin, y: height / 2))
            }
            .stroke(lineWidth: 0.5)
            .foregroundColor(.init(UIColor.subtext))
        }
        .frame(height: 3)
    }
}
