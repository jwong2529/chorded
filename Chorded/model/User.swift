//
//  User.swift
//  MusicReviewApp
//
//  Created by Janice Wong on 5/24/24.
//

import Foundation

struct User: Codable {
    var id: String
    var username: String
    var email: String
    var profilePictureURL: String
    var albumFavorites: [String] = []
}

struct UserConnections: Codable {
    var id: String
    var following: [String] = []
    var followers: [String] = []
}

struct UserReviews: Codable {
    var id: String
    var albumReviews: [String] = []
}

struct UserListenList: Codable {
    var id: String
    var listenList: [String] = []
}
