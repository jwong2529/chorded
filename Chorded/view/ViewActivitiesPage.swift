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
    
//    init() {
//        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
//    }
    
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
                            ForEach(activities, id: \.activityID) { activity in
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
            .refreshable() {
                fetchConnectionsActivities()
            }
        }
    }
        
    private func fetchConnectionsActivities() {
        guard let userID = session.currentUserID else {
            print("No current user ID found")
            return
        }

        // Fetch the following list
        FirebaseUserData().fetchFollowing(uid: userID) { followingList in
            // Include the current user's ID in the list
            var userList = followingList
            userList.append(userID)

            var allActivities: [Activity] = []
            let dispatchGroup = DispatchGroup()
            
            // Calculate the date for ten weeks ago
            let tenWeeksAgo = Calendar.current.date(byAdding: .weekOfYear, value: -10, to: Date())

            for user in userList {
                dispatchGroup.enter()
                FirebaseUserData().fetchUserActivities(userID: user) { fetchedUserActivities, error in
                    if let error = error {
                        print("Failed to fetch activities for user \(user): \(error.localizedDescription)")
                    } else if let fetchedUserActivities = fetchedUserActivities {
                        // Filter activities to include only those from the last ten weeks
                        let recentActivities = fetchedUserActivities.filter { activity in
                            if let activityDate = ISO8601DateFormatter().date(from: activity.activityTimestamp) {
                                return activityDate >= tenWeeksAgo!
                            }
                            return false
                        }
                        allActivities.append(contentsOf: recentActivities)
                    }
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) {
                // Sort all activities by activityTimestamp
                allActivities.sort { activity1, activity2 in
                    guard let timestamp1 = ISO8601DateFormatter().date(from: activity1.activityTimestamp),
                          let timestamp2 = ISO8601DateFormatter().date(from: activity2.activityTimestamp) else {
                        return false
                    }
                    return timestamp1 > timestamp2
                }
                // Assign the sorted activities to self.activities
                self.activities = allActivities
            }
        }
    }
    
}


struct AlbumReviewActivityView: View {
    let activity: Activity
    
    @EnvironmentObject var session: SessionStore
    @State private var user: User = User(userID: "", username: "", normalizedUsername: "", email: "", userProfilePictureURL: "", userBio: "")
    @State private var album: Album = Album(title: "", artistID: [0], artistNames: [""], genres: [""], styles: [""], year: 0, albumTracks: [""], coverImageURL: "")
    @State private var review: AlbumReview = AlbumReview(albumReviewID: "", userID: "", albumKey: "", rating: 0.0, reviewText: "", reviewTimestamp: "")
    @State private var username: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            NavigationLink(destination: ViewSpecificReviewPage(review: review, user: user, album: album)) {
                HStack(alignment: .top) {
                    // profile picture
                    NavigationLink(destination: ViewProfilePage(userID: user.userID)) {
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
                    // review section
                    if (!review.reviewText.isEmpty) {
                        VStack(alignment: .leading) {
                            Text("\(username) listened to")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text("\(album.title)")
                                .font(.headline)
                                .foregroundColor(.white)
                            + Text(" \(String(album.year))")
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
                                VStack {
                                    Text(review.reviewText)
                                        .multilineTextAlignment(.leading)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .padding(.leading, 10)
                                }
                                Spacer()
                            }
                        }
                    } else {
                        VStack(alignment: .leading) {
                            Text("\(username) rated ")
                                .font(.subheadline)
                                .foregroundColor(.gray)
//                                .multilineTextAlignment(.leading)
                            + Text(album.title)
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .fontWeight(.bold)
//                                .multilineTextAlignment(.leading)

                            StarRatingView(rating: review.rating)
                        }
                        .multilineTextAlignment(.leading)
                    }

                    
                    Spacer()
                    //show review date
                    let reviewDate = ISO8601DateFormatter().date(from: review.reviewTimestamp) ?? Date()
                    Text(FixStrings().timeAgoSinceDate(reviewDate))
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
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
                self.username = fetchedUser.userID == session.currentUserID ? "You" : fetchedUser.username
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
    
    @EnvironmentObject var session: SessionStore
    @State private var user: User = User(userID: "", username: "", normalizedUsername: "", email: "", userProfilePictureURL: "", userBio: "")
    @State private var album: Album = Album(title: "", artistID: [0], artistNames: [""], genres: [""], styles: [""], year: 0, albumTracks: [""], coverImageURL: "")
    @State private var username: String = ""
    
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
                NavigationLink(destination: ViewAlbumPage(albumKey: album.firebaseKey)) {
                    if (activity.activityType == .listenList) {
                        VStack(alignment: .leading) {
                            Text("\(username) added ")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            + Text(album.title)
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                            + Text(" to listen list")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .multilineTextAlignment(.leading)
                        
                    }
                    if (activity.activityType == .favorites) {
                        VStack(alignment: .leading) {
                            Text("\(username) favorited ")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            + Text(album.title)
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                        }
                        .multilineTextAlignment(.leading)
                    }
                    Spacer()
                    // get the timestamp
                    let activityDate = ISO8601DateFormatter().date(from: activity.activityTimestamp) ?? Date()
                    Text(FixStrings().timeAgoSinceDate(activityDate))
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
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
                self.username = fetchedUser.userID == session.currentUserID ? "You" : fetchedUser.username
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

