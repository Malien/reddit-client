//
//  EventEmitter.swift
//  RedditClient
//
//  Created by Yaroslav on 10.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import Foundation

struct EventEmitter<Event, Subscription> {
    let queue: DispatchQueue
    
    init(queue: DispatchQueue) {
        self.queue = queue
    }
    
    typealias SubID = SubscriptionID<Subscription>
    typealias Listener = (_ event: Event) -> Void
    
    private var listeners: [SubID: Listener] = [:]
    private var currentID = SubID.firstID
    
    func emit(event: Event) {
        for listener in listeners.values {
            queue.async {
                listener(event)
            }
        }
    }
    
    mutating func subscribe(_ listener: @escaping Listener) -> SubID {
        return queue.sync {
            let sub = currentID
            listeners[sub] = listener
            currentID = currentID.next
            return sub
        }
    }
    
    mutating func unsubscribe(_ subscription: SubID) {
        _ = queue.sync {
            self.listeners.removeValue(forKey: subscription)
        }
    }

}
