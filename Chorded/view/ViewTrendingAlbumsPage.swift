//
//  ViewTrendingAlbums.swift
//  MusicReviewApp
//
//  Created by Janice Wong on 5/25/24.
//

import Foundation
import SwiftUI

struct ViewTrendingAlbumsPage: View {
    
    let trendingAlbumKeys: [String]
//    @State private var trendingAlbums = [Album]()

//    init(trendingAlbums: [Album]) {
////        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
//        self._trendingAlbums = State(initialValue: trendingAlbums)
//        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
//    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                
                AlbumGrid(albumKeys: trendingAlbumKeys, albumCount: self.trendingAlbumKeys.count)
                    .padding(.vertical)
            }
            .navigationTitle("Trending Albums")
            
        }
    }
    
}
