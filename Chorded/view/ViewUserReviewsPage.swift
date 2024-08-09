//
//  ViewUserReviewsPage.swift
//  Chorded
//
//  Created by Janice Wong on 8/6/24.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI

struct ViewUserReviewsPage: View {
    var user: User
    @State private var userReviews: [AlbumReview] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 5) {
                        if userReviews.isEmpty {
                            Text("No reviews")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(userReviews.reversed(), id: \.albumReviewID) { review in
                                UserReviewCardView(user: user, albumReview: review)
                                Divider().overlay(Color.white)
                            }
                        }
                        Spacer()
                    }
                    .padding()
                    .onAppear() {
                        fetchUserReviews()
                    }
                    .refreshable {
                        fetchUserReviews()
                    }
                }
            }
        }
        .navigationBarTitle("Reviews", displayMode: .inline)
    }
    
    private func fetchUserReviews() {
        FirebaseUserDataManager().fetchUserReviews(uid: user.userID) { albumReviews, error in
            if let error = error {
                print("Failed to fetch user reviews: \(error.localizedDescription)")
            } else if let albumReviews = albumReviews {
                self.userReviews = albumReviews.filter {
                    !$0.reviewText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                }
            }
        }
    }
}

struct UserReviewCardView: View {
    var user: User
    var albumReview: AlbumReview
    @State private var album: Album = Album(title: "", artistID: [0], artistNames: [""], genres: [], styles: [], year: 0, albumTracks: [""], coverImageURL: "")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(album.title)
                    .font(.headline)
                    .foregroundColor(.white)
                + Text(" \(String(album.year))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            StarRatingView(rating: albumReview.rating)
            NavigationLink(destination: ViewSpecificReviewPage(review: albumReview, user: user, album: album)) {
                HStack(alignment: .top) {
                    if album.coverImageURL != "", let url = URL(string: album.coverImageURL) {
                        WebImage(url: url)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .cornerRadius(10)
                            .clipped()
                    } else {
                        PlaceholderAlbumCover(width: 50, height: 50)
                    }
                    VStack {
                        Text(albumReview.reviewText)
                            .multilineTextAlignment(.leading)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.leading, 10)
                    }
                    Spacer()
                    
                }
            }
        }
        .onAppear() {
            fetchAlbum()
        }
        .refreshable() {
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
