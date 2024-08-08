//
//  ViewUserAlbums.swift
//  Chorded
//
//  Created by Janice Wong on 8/6/24.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI

struct ViewUserAlbumsPage: View {
    var userID: String
    @State private var albumReviews: [AlbumReview] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                ScrollView() {
                    VStack {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 15) {
                            ForEach(albumReviews.reversed(), id: \.albumReviewID) { albumReview in
                                UserAlbumView(albumReview: albumReview)
                            }
                        }
                    }
                    .padding()
                    .onAppear() {
                        fetchUserReviews()
                    }
                    .refreshable {
                        fetchUserReviews()
                    }
                    .navigationBarTitle("Albums", displayMode: .inline)
                }
            }
        }
    }
    
    private func fetchUserReviews() {
        FirebaseUserData().fetchUserReviews(uid: userID) { fetchedUserReviews, error in
            if let error = error {
                print("Failed to fetch user review: \(error.localizedDescription)")
            } else if let fetchedUserReviews = fetchedUserReviews {
                self.albumReviews = fetchedUserReviews
            }
        }
    }
}

struct UserAlbumView: View {
    var albumReview: AlbumReview
    @State private var album: Album = Album(title: "", artistID: [0], artistNames: [""], genres: [], styles: [], year: 0, albumTracks: [""], coverImageURL: "")
    
    var body: some View {
        VStack {
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
            StarRatingView(rating: albumReview.rating)
        }
        .onAppear() {
            fetchAlbum()
        }
    }
    
    private func fetchAlbum() {
        FirebaseDataManager().fetchAlbum(firebaseKey: albumReview.albumKey) { fetchedAlbum, error in
            if let error = error {
                print("Failed to fetch album: \(error.localizedDescription)")
            } else if let fetchedAlbum = fetchedAlbum {
                self.album = fetchedAlbum
            }
        }
    }
}
