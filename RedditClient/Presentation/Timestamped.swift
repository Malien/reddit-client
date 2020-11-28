//
//  Post.swift
//  RedditClient
//
//  Created by Yaroslav on 28.10.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import Foundation

protocol Timestamped {
    var createdEpochUTC: TimeInterval { get }
}

extension Timestamped {
    var createdUTC: Date { Date.init(timeIntervalSince1970: createdEpochUTC) }
    
    var userReadableTimeDiff: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 1
        return formatter.string(from: -createdUTC.timeIntervalSinceNow) ?? "--:--"
    }
}
