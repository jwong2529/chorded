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
       // loadTrendingAlbums()
//        DiscogsAPIManager().testingAPI()
    }
    
    func loadTrendingAlbums() {
        DiscogsAPIManager.shared.loadTrendingAlbums()
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            let fetchedAlbums = DiscogsAPIManager.shared.getTrendingAlbums()
            DispatchQueue.main.async {
                self.albums = fetchedAlbums
            }
        }
    }
}
