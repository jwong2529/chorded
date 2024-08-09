//
//  ViewCustomListPage.swift
//  Chorded
//
//  Created by Janice Wong on 6/16/24.
//

import Foundation
import SwiftUI

struct ViewCustomListPage: View {
    let albumKeys: [String]
//    @State private var albums = [Album]()
    var listName: String
    
//    init(albums: [Album], listName: String) {
//        self.albums = albums
//        self.listName = listName
//        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
//    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                
                AlbumGrid(albumKeys: albumKeys, albumCount: self.albumKeys.count)
                    .padding(.vertical)
            }
            .navigationTitle(self.listName)
        }
    }
}
