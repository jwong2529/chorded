//
//  Activity.swift
//  Chorded
//
//  Created by Janice Wong on 8/2/24.
//

import Foundation

enum ActivityType: String {
    case albumReview = "albumReview"
    case listenList = "listenList"
    case favorites = "favorites"
}

struct Activity {
    var activityID: String
    var userID: String
    var activityTimestamp: String
    var activityType: ActivityType
    var albumID: String
    var albumReviewID: String?
    
    init(activityID: String, userID: String, activityTimestamp: String, activityType: ActivityType, albumID: String, albumReviewID: String? = "") {
        self.activityID = activityID
        self.userID = userID
        self.activityTimestamp = activityTimestamp
        self.activityType = activityType
        self.albumID = albumID
        self.albumReviewID = albumReviewID
    }
}
