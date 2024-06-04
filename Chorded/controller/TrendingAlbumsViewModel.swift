//
//  TrendingAlbumsViewModel.swift
//  MusicReviewApp
//
//  Created by Janice Wong on 5/30/24.
//

import Foundation
import Combine

class TrendingAlbumsViewModel: ObservableObject {
    @Published var albums: [Album] = []
    
    init() {
//        DiscogsAPIManager().testingAPI()
        
//        FirebaseDataManager().fetchArtist(discogsKey: 3244227) { artist, error in
//            if let error = error {
//                print("Failed to fetch artist: \(error.localizedDescription)")
//            } else if let artist = artist {
//                print("Fetched artist: \(artist)")
//            }
//        }
        
//        DiscogsAPIManager().loadTrendingAlbums()
        
//        FirebaseDataManager().fetchTrendingList { albumKeys, error in
//            if let error = error {
//                print("Failed to fetch trending album keys: \(error.localizedDescription)")
//            } else if let albumKeys = albumKeys {
//                print("Fetched trending album keys: \(albumKeys)")
//                // Do something with the fetched album keys
//            }
//        }
    }
    
}
