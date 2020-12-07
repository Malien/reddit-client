//
//  RedditClientTests.swift
//  RedditClientTests
//
//  Created by Yaroslav on 28.10.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import XCTest

class RedditClientTests: XCTestCase {
    
    var store: ApplicationStore!
    var reddit: RedditRepository!

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
        sub.cancel()
    }
    
    func testComments() throws {
        reddit.service.api.comments(for: Post.ID(string: "jrbomi")) { result in
            switch result {
            case .success(let comments):
                XCTAssertTrue(comments.children.count > 0)
            case .failure(let error):
                XCTFail("Error occurrd: \(error)")
            }
        }
        sleep(10)
    }

    func testCommentPagination() throws {
        var fetched = false
        var sub = reddit.comments(for: Post.ID(string: "jrbomi"), limit: 2) { result in
            switch result {
            case .success(let comments):
                if fetched {
                    XCTAssertEqual(comments.items.count, 4)
                } else {
                    XCTAssertEqual(comments.items.count, 2)
                    comments.fetchMore(count: 2)
                    fetched = true
                }
            case .failure(let error):
                XCTFail("Error occured: \(error)")
            }
        }
        sleep(10)
        sub.cancel()
    }
}
