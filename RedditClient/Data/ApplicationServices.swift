//
//  ApplicationServices.swift
//  RedditClient
//
//  Created by Yaroslav on 10.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import Foundation

enum ApplicationServices {
    static let dataQueue = DispatchQueue(label: "ua.edu.ukma.ios.Reddit.Data", qos: .utility)
    static let cacheQueue = DispatchQueue(label: "ua.edu.ukma.ios.Reddit.Cache", qos: .utility, target: ApplicationServices.dataQueue)
    static let store = ApplicationStore()
    static let reddit = RedditRepository(store: store)
}
