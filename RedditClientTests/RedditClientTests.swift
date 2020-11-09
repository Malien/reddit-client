//
//  RedditClientTests.swift
//  RedditClientTests
//
//  Created by Yaroslav on 28.10.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import XCTest

class RedditClientTests: XCTestCase {
    
    var store: ApplicationStore! = nil
    var reddit: RedditRepository! = nil

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        store = ApplicationStore()
        reddit = RedditRepository(store: store)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
    func testPagination() throws {
        var fetched = false
        var sub = reddit.topPosts(from: "ios", limit: 2) { result in
            switch result {
            case .success(let posts):
                if fetched {
                    XCTAssertEqual(posts.items.count, 4)
                } else {
                    XCTAssertEqual(posts.items.count, 2)
                    posts.fetchMore(count: 2)
                    fetched = true
                }
            case .failure(let error):
                XCTFail("Error occured: \(error)")
            }
        }
        sleep(10)
        sub.unsubscribe()
    }

}
