//
//  ViewActivitiesPage.swift
//  Chorded
//
//  Created by Janice Wong on 8/3/24.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI

struct ViewActivitiesPage: View {
    @State private var activities: [Activity] = []
    @State private var userConnections: [String] = []
    @EnvironmentObject var session: SessionStore
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                ScrollView {
                    VStack {
                        if activities.isEmpty {
                            Text("No recent activity")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(activities.reversed(), id: \.activityID) { activity in
                                if activity.activityType == .albumReview {
                                    AlbumReviewActivityView(activity: activity)
                                } else {
                                    ListenListFavoritesActivityView(activity: activity)
                                }
                                Divider().overlay(Color.white)
                            }
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.clear)
                }
            }
            .navigationBarTitle("Activities", displayMode: .inline)
            .onAppear() {
                fetchConnectionsActivities()
            }
        }
    }
    
    private func fetchConnectionsActivities() {
        // eventually get this to fetch all connectiosn activities but for now its just us
        // also filter for the last 10wks!
        if let userID = session.currentUserID {
            FirebaseUserData().fetchUserActivities(userID: userID) { fetchedUserActivities, error in
                if let error = error {
                    print("Failed to fetch user's activities: \(error.localizedDescription)")
                } else if let fetchedUserActivities = fetchedUserActivities {
                    self.activities = fetchedUserActivities
                }
            }
        }
    }
    
//    private func fetchUserFriends(userID: String) {
//        FirebaseUserData().fetchUserConnections(uid: userID) { fetchedFriends, error in
//            if let error = error {
//                print("Error fetching user's connections: ", error)
//            } else if let fetchedFriends = fetchedFriends {
//                
//            }
//        }
//    }
}


struct AlbumReviewActivityView: View {
    let activity: Activity
    
    @State private var user: User = User(userID: "", username: "", normalizedUsername: "", email: "", userProfilePictureURL: "", userBio: "")
    @State private var album: Album = Album(title: "", artistID: [0], artistNames: [""], genres: [""], styles: [""], year: 0, albumTracks: [""], coverImageURL: "")
    @State private var review: AlbumReview = AlbumReview(albumReviewID: "", userID: "", albumKey: "", rating: 0.0, reviewText: "", reviewTimestamp: "")
    @State private var imageSize: CGSize = .zero

    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                //profile pic
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
                    }
                }
                VStack(alignment: .leading) {
                    if (!review.reviewText.isEmpty) {
                        VStack(alignment: .leading) {
                            Text("\(user.username) listened to")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("\(album.title)  ")
                                .font(.headline)
                                .foregroundColor(.white)
                            + Text("\(String(album.year))")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            StarRatingView(rating: review.rating)
                                .padding(.top, -5)
                                .padding(.bottom, 5)
                            HStack(alignment: .top, spacing: 5) {
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
                                Text(review.reviewText)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .padding(.leading, 10)
                                Spacer()
                            }
                        }
                    } else {
                        Text("\(user.username) rated ")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        + Text(album.title)
                            .font(.subheadline)
                            .foregroundColor(.white)
                        StarRatingView(rating: review.rating)
                    }
                }
                Spacer()
                // get the timestamp
                let reviewDate = ISO8601DateFormatter().date(from: review.reviewTimestamp) ?? Date()
                Text(FixStrings().timeAgoSinceDate(reviewDate))
                    .font(.footnote)
                    .foregroundColor(.gray)
                
            }
        }
        .onAppear() {
            fetchData()
        }
    }
    
    private func fetchData() {
        // fetch albumReview -> album -> user
        fetchAlbumReview(reviewID: activity.albumReviewID ?? "", albumKey: activity.albumID)
        fetchUser(userID: activity.userID)
        fetchAlbum(albumID: activity.albumID)
    }
    
    private func fetchAlbumReview(reviewID: String, albumKey: String) {
        FirebaseDataManager().fetchSpecificAlbumReview(albumKey: albumKey, reviewID: reviewID) { fetchedReview, error in
            if let error = error {
                print("Failed to fetch album review: \(error.localizedDescription)")
            } else if let fetchedReview = fetchedReview {
                self.review = fetchedReview
            }
        }
    }
    
    private func fetchUser(userID: String) {
        FirebaseUserData().fetchUserData(uid: userID) { fetchedUser, error in
            if let error = error {
                print("Failed to fetch user data: \(error.localizedDescription)")
            } else if let fetchedUser = fetchedUser {
                self.user = fetchedUser
            }
        }
    }
    
    private func fetchAlbum(albumID: String) {
        FirebaseDataManager().fetchAlbum(firebaseKey: albumID) { fetchedAlbum, error in
            if let error = error {
                print("Error fetching album: ", error)
            } else if let fetchedAlbum = fetchedAlbum {
                self.album = fetchedAlbum
            }
        }
    }
    
}

struct ListenListFavoritesActivityView: View {
    var activity: Activity
    
    @State private var user: User = User(userID: "", username: "", normalizedUsername: "", email: "", userProfilePictureURL: "", userBio: "")
    @State private var album: Album = Album(title: "", artistID: [0], artistNames: [""], genres: [""], styles: [""], year: 0, albumTracks: [""], coverImageURL: "")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                //profile pic
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
                    }
                }
                
                if (activity.activityType == .listenList) {
                    Text("\(user.username) added ")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    + Text(album.title)
                        .font(.subheadline)
                        .foregroundColor(.white)
                    + Text(" to listen list")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                if (activity.activityType == .favorites) {
                    Text("\(user.username) favorited ")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    + Text(album.title)
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                Spacer()
                // get the timestamp
                let activityDate = ISO8601DateFormatter().date(from: activity.activityTimestamp) ?? Date()
                Text(FixStrings().timeAgoSinceDate(activityDate))
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
        .onAppear() {
            fetchData()
        }
    }
    
    private func fetchData() {
        // fetch user and album
        fetchUser(userID: activity.userID)
        fetchAlbum(albumID: activity.albumID)
    }
    
    private func fetchUser(userID: String) {
        FirebaseUserData().fetchUserData(uid: userID) { fetchedUser, error in
            if let error = error {
                print("Failed to fetch user data: \(error.localizedDescription)")
            } else if let fetchedUser = fetchedUser {
                self.user = fetchedUser
            }
        }
    }
    
    private func fetchAlbum(albumID: String) {
        FirebaseDataManager().fetchAlbum(firebaseKey: albumID) { fetchedAlbum, error in
            if let error = error {
                print("Error fetching album: ", error)
            } else if let fetchedAlbum = fetchedAlbum {
                self.album = fetchedAlbum
            }
        }
    }
}

