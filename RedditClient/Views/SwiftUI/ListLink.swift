//
//  ListCell.swift
//  RedditClient
//
//  Created by Yaroslav on 07.12.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import SwiftUI

struct ListLink<Content: View, Destination: View>: View {
    let seperated: Bool
    let destination: Destination
    let content: Content
    
    init(seperated: Bool = true, destination: Destination, content: () -> Content) {
        self.seperated = seperated
        self.destination = destination
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                NavigationLink(destination: destination) {
                    content
                        .padding(.horizontal)
                        Spacer()
                        ListLinkIndicatior()
                            .frame(maxWidth: 8, maxHeight: 16)
                            .padding(12)
                            .padding(.trailing, 14)
                    
                }
            }
            if seperated {
                ListSeparator()
                    .frame(height: 3)
            }
        }
    }
}

struct ListCell_Previews: PreviewProvider {
    static func dest() -> some View { Text("destination") }

    static func collection() -> some View {
        Group {
            ListLink(destination: dest()) {
                Text("Lorem ipsum")
            }
            .previewDisplayName("Single link cell")
            
            VStack {
                ForEach(Range(1...5)) { count in
                    ListLink(destination: dest()) {
                        Text("This is row #\(count) with link")
                    }
                }
            }
            .previewDisplayName("List of rows with links")
            
            VStack {
                ForEach(Range(1...5)) { count in
                    ListLink(seperated: false, destination: dest()) {
                        Text("This is row #\(count) without separator")
                    }
                }
            }
            .previewDisplayName("List of rows without the separator")
        }
        .background(Color(UIColor.background))
    }
    
    static var previews: some View {
        Group {
            collection()
            collection()
                .environment(\.colorScheme, .dark)
        }
        .previewLayout(.sizeThatFits)
    }
}
