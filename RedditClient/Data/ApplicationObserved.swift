//
//  ApplicationObserved.swift
//  RedditClient
//
//  Created by Yaroslav on 10.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import Foundation

@propertyWrapper
struct ApplicationObserved<T> {
    let observed: Observed<T>
    var wrappedValue: T {
        get {
            observed.wrappedValue
        }
        set {
            observed.wrappedValue = newValue
        }
    }
    var projectedValue: Observed<T> { observed }
    
    init(wrappedValue: T) {
        observed = Observed(wrappedValue: wrappedValue, queue: ApplicationServices.dataQueue)
    }
}

extension ApplicationObserved : Codable where T: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(T.self)
        self.init(wrappedValue: value)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}
