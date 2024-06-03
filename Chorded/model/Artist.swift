//
//  Artist.swift
//  MusicReviewApp
//
//  Created by Janice Wong on 5/30/24.
//

import Foundation

struct Artist: Decodable {
    let name: String
    let discogsID: Int
//    let firebaseKey: String
    var image: String
    var albums: [String] //album IDs
    
    init(name: String, discogsID: Int, image: String) {
        self.name = name
//        self.firebaseKey = ""
        self.discogsID = discogsID
        self.image = image
        self.albums = []
    }
    
//    mutating func addAlbum(album: Int) {
//        albums.append(album)
//    }
    
//    struct ArtistImage: Decodable {
//        let uri: String
//    }
    
//    enum CodingKeys: CodingKey {
//        case name
//        case id
//        case images
//    }
//    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        name = try container.decode(String.self, forKey: .name)
//        id = try container.decode(Int.self, forKey: .id)
//        images = try container.decode([ArtistImage].self, forKey: .images)
//    }
    
}


