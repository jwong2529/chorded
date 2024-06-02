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
    var friends: [User]
    
    init(id: String, username: String, email: String, profilePictureURL: URL) {
        self.id = id
        self.username = username
        self.email = email
        self.profilePictureURl = profilePictureURL
        self.albumReviews = []
        self.albumFavorites = []
        self.friends = []
    }
    
    func addAlbumReview(review: AlbumReview) {
        albumReviews.append(review)
    }
    
    func addAlbumFavorite(album: Album) {
        albumFavorites.append(album)
    }
    
    func addFriend(_ user: User) {
        // ensures that user is not the same user and is not already a friend
        guard user.id != self.id && !friends.contains(where: {$0.id == user.id}) else { return }
        friends.append(user)
    }
    
    func removeFriend(_ user: User) {
        friends.removeAll {$0.id == user.id }
    }
    
    func listFriends() -> [User] {
        return friends
    }
}
