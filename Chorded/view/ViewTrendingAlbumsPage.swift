//
//  ViewTrendingAlbums.swift
//  MusicReviewApp
//
//  Created by Janice Wong on 5/25/24.
//

import Foundation
import SwiftUI

struct ViewTrendingAlbumsPage: View {
    
    @State private var trendingAlbums = [Album]()
    
    init() {
//        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                
                AlbumGrid(albums: trendingAlbums, albumCount: self.trendingAlbums.count)
                    .padding(.bottom)
            }
            .navigationTitle("Trending Albums")
            
            .onAppear {
                fetchTrendingAlbums()
            }
        }
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
