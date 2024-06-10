//
//  Album.swift
//  MusicReviewApp
//
//  Created by Janice Wong on 5/24/24.
//

import Foundation

struct Album: Decodable {
//    let discogsID: Int
    var firebaseKey: String
    let title: String
    let artistID: [Int]  //artist ID Strings
    let artistNames: [String]
    let genres: [String]?
    let styles: [String]?
    let year: Int
    let albumTracks: [String]
    let coverImageURL: String
    var albumRating: Double?
//    var albumReviews: [String] //album ID
    
    init(title: String, artistID: [Int], artistNames: [String], genres: [String]?, styles: [String]?, year: Int, albumTracks: [String], coverImageURL: String) {
//        self.discogsID = discogsID
        self.firebaseKey = ""
        self.title = title
        self.artistID = artistID
        self.artistNames = artistNames
        self.genres = genres
        self.styles = styles
        self.year = year
//        self.albumReviews = []
        self.albumTracks = albumTracks
        self.coverImageURL = coverImageURL
        self.albumRating = nil
    }
    
//    mutating func addAlbumReview(review: String) {
//        albumReviews.append(review)
//    }
    
}
