//
//  AlbumReview.swift
//  MusicReviewApp
//
//  Created by Janice Wong on 5/24/24.
//

import Foundation

struct AlbumReview: Decodable {
    var albumReviewID: String
    var userID: String
    var albumKey: String
    var rating: Double
    var reviewText: String
    var reviewTimestamp: String
    
    init(albumReviewID: String, userID: String, albumKey: String, rating: Double, reviewText: String, reviewTimestamp: String) {
        self.albumReviewID = albumReviewID
        self.userID = userID
        self.albumKey = albumKey
        self.rating = rating
        self.reviewText = reviewText
        self.reviewTimestamp = reviewTimestamp
    }
}
