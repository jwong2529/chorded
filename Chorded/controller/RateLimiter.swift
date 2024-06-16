//
//  RateLimiter.swift
//  Chorded
//
//  Created by Janice Wong on 6/15/24.
//

import Foundation

class RateLimiter {
    private let maxApiCallsPerMinute = 59
    private let windowInterval: TimeInterval = 60
    private var apiCallsCount = 0
    private var windowStartTime = Date()

    func executeRequest(requiredSlots: Int, completion: @escaping () -> Void) {
        let currentTime = Date()
        if currentTime.timeIntervalSince(windowStartTime) >= windowInterval {
            windowStartTime = currentTime
            apiCallsCount = 0
        }

        if apiCallsCount + requiredSlots <= maxApiCallsPerMinute {
            apiCallsCount += requiredSlots
            completion()
        } else {
            let waitTime = windowInterval - currentTime.timeIntervalSince(windowStartTime)
            DispatchQueue.global().asyncAfter(deadline: .now() + waitTime) {
                self.executeRequest(requiredSlots: requiredSlots, completion: completion)
            }
        }
    }
}
