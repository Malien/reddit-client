//
//  AppDelegate.swift
//  RedditClient
//
//  Created by Yaroslav on 28.10.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import UIKit

let store = ApplicationStore()
let reddit = RedditRepository(store: store)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let controller = SinglePostViewController()
        window!.rootViewController = controller
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
