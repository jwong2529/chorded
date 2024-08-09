//
//  AlbumGrid.swift
//  Chorded
//
//  Created by Janice Wong on 6/4/24.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI

struct AlbumGrid: View {
    let albumKeys: [String]
    @State private var albums: [Album] = []
    let albumCount: Int
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 15) {
                ForEach(albums, id: \.firebaseKey) { album in
                    NavigationLink(destination: ViewAlbumPage(albumKey: album.firebaseKey)) {
                        if album.coverImageURL != "", let url = URL(string: album.coverImageURL) {
                            WebImage(url: url)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 150, height: 150)
                                .clipped()
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        } else {
                            PlaceholderAlbumCover(width: 150, height: 150)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .onAppear() {
                fetchAlbums(albumKeys: albumKeys)
            }
        }
    }
    
    private func fetchAlbums(albumKeys: [String]) {
        print(albumKeys)
        let dispatchGroup = DispatchGroup()
        var albums = [Album]()
        var fetchErrors = [Error]()
        
        for key in albumKeys {
            dispatchGroup.enter()
            FirebaseDataManager().fetchAlbum(firebaseKey: key) { album, error in
                if let album = album {
                    albums.append(album)
                }
                if let error = error {
                    fetchErrors.append(error)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            if fetchErrors.isEmpty {
                self.albums = albums
            } else {
                print("Errors fetching albums: \(fetchErrors)")
            }
        }
    }
}
