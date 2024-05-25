//
//  User.swift
//  MusicReviewApp
//
//  Created by Janice Wong on 5/24/24.
//

import Foundation

class User {
    let id: String
    var username: String
    var email: String
    var profilePictureURl: URL
    var albumReviews: [AlbumReview]
    var albumFavorites: [Album]
    
    init(id: String, username: String, email: String, profilePictureURL: URL) {
        self.id = id
        self.username = username
        self.email = email
        self.profilePictureURl = profilePictureURL
        self.albumReviews = []
        self.albumFavorites = []
    }
    
    func addAlbumReview(review: AlbumReview) {
        albumReviews.append(review)
    }
    
    func addAlbumFavorite(album: Album) {
        albumFavorites.append(album)
    }
}
