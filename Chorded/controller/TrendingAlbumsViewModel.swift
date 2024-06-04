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
        
//        DiscogsAPIManager().loadTrendingAlbums()
        
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
    }
    
    func fetchTrendingAlbums() {
        var fetchedAlbums: [Album] = []
        let dispatchGroup = DispatchGroup()
        
        FirebaseDataManager().fetchTrendingList { albumKeys, error in
            if let error = error {
                print("Failed to fetch trending album keys: \(error.localizedDescription)")
            } else if let albumKeys = albumKeys {
                print("Fetched trending album keys: \(albumKeys)")
                for albumKey in albumKeys {
                    dispatchGroup.enter()
                    FirebaseDataManager().fetchAlbum(firebaseKey: albumKey) { album, error in
                        if let error = error {
                            print("Failed to fetch trending album: \(error.localizedDescription)")
                        } else if let album = album {
                            print("Fetched album: \(album.title)")
                            fetchedAlbums.append(album)
                        }
                        dispatchGroup.leave()
                    }
                }
                dispatchGroup.notify(queue: .main) {
                    self.trendingAlbums = fetchedAlbums
                    print(self.trendingAlbums.count)

                }
            }
        }
    }
    
}
