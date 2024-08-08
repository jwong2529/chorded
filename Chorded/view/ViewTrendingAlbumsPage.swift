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

    init(trendingAlbums: [Album]) {
//        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        self._trendingAlbums = State(initialValue: trendingAlbums)
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                
                AlbumGrid(albums: trendingAlbums, albumCount: self.trendingAlbums.count)
                    .padding(.vertical)
            }
            .navigationTitle("Trending Albums")
            
        }
    }
    
}
