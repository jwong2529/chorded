//
//  Artist.swift
//  MusicReviewApp
//
//  Created by Janice Wong on 5/30/24.
//

import Foundation

struct Artist {
    let name: String
    let id: Int
    var image: String?
    var albums: [Album] = []
    
    init(name: String, id: Int, image: String? = nil) {
        self.name = name
        self.id = id
        self.image = image
    }
    
    mutating func addAlbum(album: Album) {
        albums.append(album)
    }
    
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


