//
//  User.swift
//  MusicReviewApp
//
//  Created by Janice Wong on 5/24/24.
//

import Foundation

struct User: Decodable {
    var userID: String
    var username: String
    var email: String
    var userProfilePictureURL: String
    var userAlbumFavorites: [String]?
    
    init(userID: String, username: String, email: String, userProfilePictureURL: String) {
        self.userID = userID
        self.username = username
        self.email = email
        self.userProfilePictureURL = userProfilePictureURL
        self.userAlbumFavorites = []
    }
}

struct UserConnections: Decodable {
    var userID: String
    var following: [String]?
    var followers: [String]?
    
    init(userID: String) {
        self.userID = userID
        self.following = []
        self.followers = []
    }
}

struct UserReviews: Decodable {
    var userID: String
    var userAlbumReviews: [String]?
    
    init(userID: String) {
        self.userID = userID
        self.userAlbumReviews = []
    }
}

struct UserListenList: Decodable {
    var userID: String
    var userListenList: [String]?
    
    init(userID: String) {
        self.userID = userID
        self.userListenList = []
    }
}
