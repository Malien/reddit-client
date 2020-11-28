//
//  ApplicationServices.swift
//  RedditClient
//
//  Created by Yaroslav on 10.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import Foundation
import os

final class ApplicationServices {
    static let dataQueue = DispatchQueue(label: "ua.edu.ukma.ios.Reddit.Data", qos: .utility)
    static let cacheQueue = DispatchQueue(label: "ua.edu.ukma.ios.Reddit.Cache", qos: .utility, target: ApplicationServices.dataQueue)
    static let ioQueue = DispatchQueue(label: "ua.edu.ukma.ios.Reddit.io", qos: .background)
    static let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"]! as! String
    
    static let APIBaseURL = URL(staticString: "https://www.reddit.com")
    
    static var shared: ApplicationServices!
    static func loadFromDisk() {
        do {
            // TODO: migrations
            let store = try ApplicationStore.load(version: version)
            shared = ApplicationServices(store: store)
        } catch let error {
            print(error)
            shared = ApplicationServices()
        }
    }
    
    var store: ApplicationStore
    var reddit: RedditRepository
    
    init(store: ApplicationStore = ApplicationStore()) {
        self.store = store
        self.reddit = RedditRepository(store: store, baseURL: Self.APIBaseURL)
    }
    
}
