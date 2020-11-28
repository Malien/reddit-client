//
//  AppDelegate.swift
//  RedditClient
//
//  Created by Yaroslav on 28.10.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // statics init
        _ = ApplicationServices.version
        ApplicationServices.loadFromDisk()
        
        window = UIWindow(frame: UIScreen.main.bounds)
//        let controller = PostListViewController(subreddit: "ios")
        let controller = CommentListViewController(for: PostID(string: "jrbomi"), batchSize: 100)
        let navigation = UINavigationController(rootViewController: controller)
        window!.rootViewController = navigation
        window!.makeKeyAndVisible()
        
        return true
    }

}

extension UIView {
    @discardableResult
    func autolayouted() -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }
}
