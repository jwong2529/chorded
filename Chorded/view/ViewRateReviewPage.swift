//
//  ViewRateReviewPage.swift
//  MusicReviewApp
//
//  Created by Janice Wong on 5/25/24.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI

struct ViewRateReviewPage: View {
    @Binding var showRateReviewPage: Bool
    @State private var searchText = ""
    @State private var albums = [AlbumIndex]()
//    @State private var selectedAlbum: AlbumIndex?
    @State private var selectedAlbumObj: Album?
    @State private var showReviewModal = false
    // need this state to make sure album is fetched before showing review modal
    @State private var isFetchingAlbum = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                VStack (spacing: 5) {
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
            .sheet(isPresented: $showReviewModal, onDismiss: {
                // reset states when modal is dismissed
                self.selectedAlbumObj = nil
            }) {
                if let album = selectedAlbumObj {
                    PostReviewModal(showModal: self.$showReviewModal, album: album)
                }
            }
            .navigationBarItems(
                leading: Button("Cancel") {
                    showRateReviewPage = false
                },
                trailing: ProfilePicture()
            )
            .navigationBarTitle("Review an album", displayMode: .inline)
            // do not delete, this makes sure the sheet is presented once the album is fully fetched, during the wait it shows a loading spinner
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
                    self.selectedAlbumObj = album
                    self.showReviewModal = true
                    self.isFetchingAlbum = false
                }
            }
        }
    }
}

struct ProfilePicture: View {
    var body: some View {
        // replace with actual user's profile pic later
        Image("profilePic")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 20, height: 20)
            .clipShape(Circle())
    }
}
