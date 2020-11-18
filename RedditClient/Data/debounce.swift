//
//  Debouncer.swift
//  RedditClient
//
//  Created by Yaroslav on 11.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import Foundation

func debounce(timeout: DispatchTimeInterval, queue: DispatchQueue, closure: @escaping () -> Void) -> (() -> Void) {
    var awaitedTask: DispatchWorkItem?
    
    let timeouted = {
        awaitedTask?.cancel()
        let task = DispatchWorkItem(block: closure)
        awaitedTask = task
        queue.asyncAfter(deadline: DispatchTime.now() + timeout, execute: task)
    }
    
    return timeouted
}
