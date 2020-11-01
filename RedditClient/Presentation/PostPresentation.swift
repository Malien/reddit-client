//
//  Post.swift
//  RedditClient
//
//  Created by Yaroslav on 28.10.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import Foundation


extension Post {
    var created: Date { Date.init(timeIntervalSince1970: createdEpoch) }
    var createdUTC: Date { Date.init(timeIntervalSince1970: createdUTCEpoch) }
    
    var userReadableTimeDiff: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 1
        return formatter.string(from: -createdUTC.timeIntervalSinceNow) ?? "--:--"
    }
}
