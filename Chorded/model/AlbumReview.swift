//
//  AlbumReview.swift
//  MusicReviewApp
//
//  Created by Janice Wong on 5/24/24.
//

import Foundation

struct AlbumReview: Identifiable {
    var id: String
    var userID: String
    var albumKey: String
    var rating: Double
    var reviewText: String
    var timestamp: String
    
    init(id: String, userID: String, albumKey: String, rating: Double, reviewText: String, timestamp: String) {
        self.id = id
        self.userID = userID
        self.albumKey = albumKey
        self.rating = rating
        self.reviewText = reviewText
        self.timestamp = timestamp
    }
}
