//
//  ViewArtistPage.swift
//  Chorded
//
//  Created by Janice Wong on 6/13/24.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI

struct ViewArtistPage: View {
    let artistID: Int
    @State private var artist = Artist(name: "", profileDescription: "", discogsID: 0, imageURL: "")
    @State private var profileDescriptionIsExpanded = false
    @State private var albums: [Album] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Spacer()
                            if artist.imageURL != "", let url = URL(string: artist.imageURL) {
                                WebImage(url: url)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .shadow(color: .blue, radius: 5)
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .padding(.top, 16)
                            } else {
                                PlaceholderArtistImage(width: 120, height: 120)
                            }
                            Spacer()
                        }
                        
                        HStack {
                            Spacer()
                            Text(artist.name)
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            Spacer()
                        }
                        
                        Text(artist.profileDescription)
                            .lineLimit(profileDescriptionIsExpanded ? nil : 2)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                            .onTapGesture {
                                withAnimation {
                                    profileDescriptionIsExpanded.toggle()
                                }
                            }
                        
                        if !artist.albums.isEmpty {
                            Text("Albums")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            AlbumGrid(albums: albums, albumCount: albums.count)
                        }
                    }
                    .padding(.bottom, 16)
                }
            }
            
            .onAppear {
                fetchData()
            }
        }
        .navigationTitle(artist.name)
    }
    
    private func fetchData() {
        fetchArtist(discogsID: artistID)
    }
    
    func fetchArtist(discogsID: Int) {
        FirebaseDataManager().fetchArtist(discogsKey: discogsID) { fetchedArtist, error in
            if let error = error {
                print("Error fetching artist:", error)
            } else if let fetchedArtist = fetchedArtist {
                self.artist = fetchedArtist
                fetchAlbums(albumIDs: fetchedArtist.albums)
            }
        }
    }
    func fetchAlbums(albumIDs: [String]) {
        var fetchedAlbums: [Album] = []
        let dispatchGroup = DispatchGroup()
        
        for albumID in albumIDs {
            dispatchGroup.enter()
            FirebaseDataManager().fetchAlbum(firebaseKey: albumID) { album, error in
                if let album = album {
                    fetchedAlbums.append(album)
                } else {
                    print("Failed to fetch album: \(error?.localizedDescription ?? "Unknown error")")
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.albums = fetchedAlbums
        }
    }
}
