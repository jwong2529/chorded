//
//  AlbumReview.swift
//  MusicReviewApp
//
//  Created by Janice Wong on 5/24/24.
//

import Foundation

struct AlbumReview {
    let userId: String
    let albumTitle: String
    let rating: Float
    let review: String?
    
    init(userID: String, albumTitle: String, rating: Float, review: String) {
        self.userId = userID
        self.albumTitle = albumTitle
        self.rating = rating
        self.review = review
    }
}
