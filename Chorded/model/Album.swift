//
//  Album.swift
//  MusicReviewApp
//
//  Created by Janice Wong on 5/24/24.
//

import Foundation

struct Album {
    let discogsID: Int
    let title: String
    let artists: [Artist]
    let genres: [String]
    let styles: [String]
    let year: Int
    let albumTracks: [String]
    let coverImageURL: String
    var albumReviews: [AlbumReview]
    
    init(discogsID: Int, title: String, artists: [Artist], genres: [String], styles: [String], year: Int, albumTracks: [String], coverImageURL: String) {
        self.discogsID = discogsID
        self.title = title
        self.artists = artists
        self.genres = genres
        self.styles = styles
        self.year = year
        self.albumReviews = []
        self.albumTracks = albumTracks
        self.coverImageURL = coverImageURL
    }
    
    mutating func addAlbumReview(review: AlbumReview) {
        albumReviews.append(review)
    }
}
