//
//  ViewSpecificReviewPage.swift
//  Chorded
//
//  Created by Janice Wong on 8/5/24.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI

struct ViewSpecificReviewPage: View {
    @EnvironmentObject var session: SessionStore
    var review: AlbumReview
    var user: User
    var album: Album
    
    @State private var showEditReviewModal = false
    @State private var showActionSheet = false
    @State private var showDeleteReviewAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack (alignment: .top) {
                            VStack (alignment: .leading, spacing: 8) {
                                NavigationLink(destination: ViewProfilePage(userID: user.userID)) {
                                    HStack {
                                        if let url = URL(string: user.userProfilePictureURL) {
                                            WebImage(url: url)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 25, height: 25)
                                                .clipShape(Circle())
                                        } else {
                                            PlaceholderUserImage(width: 25, height: 25)
                                        }
                                        
                                        VStack(alignment: .leading) {
                                            Text(user.username)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                Text("\(album.title)  ")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                + Text("\(String(album.year))")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                StarRatingView(rating: review.rating)
                                    .padding(.bottom, 4)
                                Text("Listened ")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                + Text(formatTimestamp(review.reviewTimestamp))
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            NavigationLink(destination: ViewAlbumPage(albumKey: album.firebaseKey)) {
                                if album.coverImageURL != "", let url = URL(string: album.coverImageURL) {
                                    WebImage(url: url)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 80, height: 80)
                                        .cornerRadius(10)
                                        .clipped()
                                } else {
                                    PlaceholderAlbumCover(width: 80, height: 80)
                                }
                            }
                        }
                        Text(review.reviewText)
                            .font(.footnote)
                        Divider().overlay(Color.white)
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationBarTitle("Review", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if user.userID == session.currentUserID {
                        Button(action: {
                            showActionSheet = true
                        }) {
                            Image(systemName: "ellipsis")
                        }
                        .actionSheet(isPresented: $showActionSheet) {
                            actionSheet
                        }
                        .alert(isPresented: $showDeleteReviewAlert) {
                            deleteReviewAlert
                        }
                    }
                }
            }
            .sheet(isPresented: $showEditReviewModal) {
                PostReviewModal(showModal: self.$showEditReviewModal, album: self.album)
            }
        }
    }
    
    private func deleteReview() {
        FirebaseDataManager().deleteAlbumReview(userID: user.userID, albumID: album.firebaseKey, reviewID: review.albumReviewID) { error in
            if let error = error {
                print("Failed to delete review: \(error.localizedDescription)")
            }
        }
    }
    
    private var deleteReviewAlert: Alert {
        Alert(
            title: Text(""),
            message: Text("Are you sure you want to delete this review?"),
            primaryButton: .destructive(Text("Delete")) {
                deleteReview()
            },
            secondaryButton: .cancel()
        )
    }
    
    private var actionSheet: ActionSheet {
        ActionSheet(title: Text("Options"), buttons: [
            .default(Text("Edit Review")) {
                showEditReviewModal = true
            },
            .destructive(Text("Delete Review")) {
                showDeleteReviewAlert = true
            },
            .cancel()
        ])
    }
    
    private func formatTimestamp(_ isoTimestamp: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: isoTimestamp) {
            return dateFormatter.string(from: date)
        } else {
            return isoTimestamp
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()
