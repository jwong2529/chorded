//
//  User.swift
//  MusicReviewApp
//
//  Created by Janice Wong on 5/24/24.
//

import Foundation

struct User: Identifiable, Decodable {
    var id: String
    var username: String
    var email: String
    let profilePictureURL: String
    let albumFavorites: [String]?
    
    init(id: String, username: String, email: String, profilePictureURL: String) {
        self.id = id
        self.username = username
        self.email = email
        self.profilePictureURL = profilePictureURL
        self.albumFavorites = []
    }
}

struct UserConnections: Identifiable, Decodable {
    var id: String
    let following: [String]?
    let followers: [String]?
    
    init(id: String) {
        self.id = id
        self.following = []
        self.followers = []
    }
}

struct UserReviews: Identifiable, Decodable {
    var id: String
    let albumReviews: [String]?
    
    init(id: String) {
        self.id = id
        self.albumReviews = []
    }
}

struct UserListenList: Identifiable, Decodable {
    var id: String
    let listenList: [String]?
    
    init(id: String) {
        self.id = id
        self.listenList = []
    }
}
