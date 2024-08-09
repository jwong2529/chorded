//
//  AlbumListCard.swift
//  Chorded
//
//  Created by Janice Wong on 6/16/24.
//

import Foundation
import SwiftUI

struct AlbumListCard: View {
    var title: String
    var gradientColors: [Color]
    var design: String
    var albumKeys: [String]
    @State private var albums: [Album] = []

    var body: some View {
        VStack {
            
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .default))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(.top, 20)
                .padding(.bottom, 10)
                        
            if design == "fanned" {
                HStack {
                    Spacer()
                    FannedAlbums(albums: albums)
                    Spacer()
                }
            } else if design == "vinyl" {
                SpinningVinyl()
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .topLeading, endPoint: .bottomTrailing))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        
        .onAppear {
            fetchAlbums(albumKeys: albumKeys)
        }
    }
    
    private func fetchAlbums(albumKeys: [String]) {
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

//#Preview {
//    ViewHomePage()
//}
