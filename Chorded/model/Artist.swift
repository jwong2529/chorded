//
//  Artist.swift
//  MusicReviewApp
//
//  Created by Janice Wong on 5/30/24.
//

import Foundation

struct Artist: Decodable, Identifiable {
    let name: String
    let profileDescription: String
    let discogsID: Int
//    let firebaseKey: String
    var imageURL: String
    var albums: [String] //album IDs
    
    init(name: String, profileDescription: String, discogsID: Int, imageURL: String) {
        self.name = name
        self.profileDescription = profileDescription
//        self.firebaseKey = ""
        self.discogsID = discogsID
        self.imageURL = imageURL
        self.albums = []
    }
    
    // Conform to Identifiable
    var id: Int {
        return discogsID
    }

    
}


