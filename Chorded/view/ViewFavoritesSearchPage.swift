//
//  ViewFavoritesSearchPage.swift
//  Chorded
//
//  Created by Janice Wong on 8/7/24.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI

struct ViewFavoritesSearchPage: View {
    var user: User
    @Binding var showModal: Bool
    @State private var searchText = ""
    @State private var albums = [AlbumIndex]()
    @Binding var selectedAlbum: Album?
    @State private var isFetchingAlbum = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                //select an album
                VStack(spacing: 5) {
                    if !albums.isEmpty {
                        List(albums.prefix(5)) { album in
                            Button(action: {
                                fetchAlbumObj(albumIndex: album)
                            }) {
                                HStack {
                                    if let url = URL(string: album.coverImageURL) {
                                        WebImage(url: url)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 50, height: 50)
                                            .clipped()
                                            .cornerRadius(10)
                                            .shadow(radius: 5)
                                    } else {
                                        PlaceholderAlbumCover(width: 50, height: 50)
                                    }
                                    VStack(alignment: .leading) {
                                        Text(album.title)
                                            .font(.headline)
                                    }
                                }
                            }
                            .listRowBackground(Color.gray.opacity(0.2))
                        }
                        .listStyle(InsetGroupedListStyle())
                        .background(Color.gray.opacity(0.2))
                        .scrollContentBackground(.hidden)
                    } else {
                        Spacer()
                    }
                }
                .searchable(text: $searchText, prompt: "Search albums")
                .onChange(of: searchText) { newValue in
                    SearchData().searchAlbums(with: newValue) { results in
                        self.albums = results
                    }
                }
            }
            .navigationBarTitle("Select an Album", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    showModal = false
                },
                trailing: ProfilePicture(user: user)
            )
            .overlay(
                Group {
                    if isFetchingAlbum {
                        ProgressView("Loading...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
    //                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                    }
                }
            )
        }
    }
    
    private func fetchAlbumObj(albumIndex: AlbumIndex) {
        isFetchingAlbum = true
        FirebaseDataManager().fetchAlbum(firebaseKey: albumIndex.id) { album, error in
            if let error = error {
                print("Failed to fetch album: \(error.localizedDescription)")
            } else if let album = album {
                DispatchQueue.main.async {
                    self.selectedAlbum = album
                    self.showModal = false
                    self.isFetchingAlbum = false
                }
            }
        }
    }
}
