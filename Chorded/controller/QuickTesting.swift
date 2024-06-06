//
//  QuickTesting.swift
//  Chorded
//
//  Created by Janice Wong on 6/4/24.
//


import Foundation
import Combine

class QuickTesting: ObservableObject {
    @Published var albums: [Album] = []
    private var trendingAlbums = [Album]()
    
    init() {
//        DiscogsAPIManager().testingAPI()
        
//        FirebaseDataManager().fetchArtist(discogsKey: 3244227) { artist, error in
//            if let error = error {
//                print("Failed to fetch artist: \(error.localizedDescription)")
//            } else if let artist = artist {
//                print("Fetched artist: \(artist)")
//            }
//        }
        
        DiscogsAPIManager().loadTrendingAlbums()
        
//        FirebaseDataManager().fetchTrendingList { albumKeys, error in
//            if let error = error {
//                print("Failed to fetch trending album keys: \(error.localizedDescription)")
//            } else if let albumKeys = albumKeys {
//                print("Fetched trending album keys: \(albumKeys)")
//                // Do something with the fetched album keys
//            }
//        }
        
//        FirebaseDataManager().fetchAlbum(firebaseKey: "-NzV_bo6GDTDILFXd3dX") { album, error in
//            if let error = error {
//                print("Failed to fetch album: \(error.localizedDescription)")
//            } else if let album = album {
//                print("Fetched artist: \(album.title)")
//            }
//        }
        
//        fetchTrendingAlbums()
        
//        let testTitle = "cowboy carter"
//        let testArtists = ["Beyonce"]
//        FirebaseDataManager().doesAlbumExist(title: testTitle, artists: testArtists) { exists, firebaseKey in
//            if exists {
//                print("\(testTitle) exists with key: \(firebaseKey ?? "No key)")")
//            } else {
//                print("Album does not exist")
//            }
//        }
        
//        let testString = "Travis Scott (2)"
//        print(FixStrings().deleteDistinctArtistNum(testString))
        
    }
    
    
}
