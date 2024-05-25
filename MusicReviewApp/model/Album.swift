//
//  Album.swift
//  MusicReviewApp
//
//  Created by Janice Wong on 5/24/24.
//

import Foundation

struct Album {
    let title: String
    let artist: String
    var albumReviews: [AlbumReview]
    var coverImageURl: URL?
    
    init(title: String, artist: String, coverImageURl: URL? = nil) {
        self.title = title
        self.artist = artist
        self.albumReviews = []
        self.coverImageURl = coverImageURl
    }
    
    mutating func addAlbumReview(review: AlbumReview) {
        albumReviews.append(review)
    }
}
