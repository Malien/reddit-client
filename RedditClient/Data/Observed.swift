//
//  Observed.swift
//  RedditClient
//
//  Created by Yaroslav on 10.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import Foundation

@propertyWrapper
final class Observed<T> {
    var wrappedValue: T {
        didSet {
            eventEmitter.emit(event: wrappedValue)
        }
    }
    typealias EE = EventEmitter<T, Observed<T>>
    var eventEmitter: EE
    
    var projectedValue: Self { self }
    
    init(wrappedValue: T, queue: DispatchQueue) {
        self.wrappedValue = wrappedValue
        self.eventEmitter = EventEmitter(queue: queue)
    }

    func subscribe(_ listener: @escaping EE.Listener) -> EE.SubID {
        eventEmitter.subscribe(listener)
    }

    func unsubscribe(_ subscription: EE.SubID) {
        eventEmitter.unsubscribe(subscription)
    }

}

