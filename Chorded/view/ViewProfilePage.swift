//
//  ViewProfile.swift
//  MusicReviewApp
//
//  Created by Janice Wong on 5/25/24.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI

struct ViewProfilePage: View {
    var userID: String

    @EnvironmentObject var session: SessionStore
    @State private var isCurrentUser: Bool = false
    @State private var user: User = User(userID: "", username: "", normalizedUsername: "", email: "", userProfilePictureURL: "", userBio: "")
    @State private var isFollowing: Bool = false
    
    
    @State private var followingCount: String = ""
    @State private var followersCount: String = ""
    @State private var reviewsCount: String = ""
    
    @State private var favoriteAlbums: [Album] = []
    @State private var recentActivities: [Activity] = []
    
    @State private var listenListCount: String = ""
    @State private var allAlbumReviewsCount: String = ""
    
    // for logging out a user
    @State private var showActionSheet = false
    @State private var showLogoutAlert = false
    @State private var navigateToEditProfile = false
    
    @State private var isLoading = true
    
//    init() {
//        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
//    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                
                ScrollView {
                    if !isLoading {
                        VStack {
                            HStack {
                                Spacer()
                                if let url = URL(string: user.userProfilePictureURL) {
                                    WebImage(url: url)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .shadow(color: .blue, radius: 5)
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                                } else {
                                    PlaceholderUserImage(width: 120, height: 120)
                                        .shadow(color: .blue, radius: 5)
                                }
                                Spacer()
                            }
                            
                            if !isCurrentUser {
                                Button(action: {
                                    if isFollowing {
                                        FirebaseUserDataManager().unfollowUser(currentUserID: session.currentUserID ?? "", unfollowedUserID: userID)
                                    } else {
                                        FirebaseUserDataManager().followUser(currentUserID: session.currentUserID ?? "", followedUserID: userID)
                                    }
                                    isFollowing.toggle()
                                }) {
                                    Text(isFollowing ? "Unfollow": "Follow")
                                        .padding(.vertical, 5)
                                        .padding(.horizontal, 20)
                                        .background(isFollowing ? Color.blue.opacity(0.3) : Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                                .padding(5)
                            }
                            VStack(alignment: .leading, spacing: 5) {
                                
                                if !user.userBio.isEmpty {
                                    HStack {
                                        Spacer()
                                        Text(user.userBio)
                                            .font(.body)
                                            .foregroundColor(.gray)
                                            .multilineTextAlignment(.center)
                                        Spacer()

                                    }
                                }
                                
                                HStack {
                                    Spacer()
                                    ProfilePageQuickInfo(user: user, followingCount: followingCount, followersCount: followersCount, reviewsCount: reviewsCount)
                                    Spacer()
                                }
                                
                                Spacer()
                                
                                if !favoriteAlbums.isEmpty {
                                    Divider().overlay(Color.white)

                                    ProfilePageFavoritesView(favoriteAlbums: favoriteAlbums)
                                        .padding(.bottom, 5)
                                }
                                
                                if !recentActivities.isEmpty {
                                    Divider().overlay(Color.white)

                                    ProfilePageRecentActivityView(user: user, activities: recentActivities)
                                    
                                    Divider().overlay(Color.white)
                                        .padding(.bottom, 20)
                                }
                                
                                ProfilePageInfoLists(user: user, allAlbumsCount: "\(allAlbumReviewsCount)", allReviewsCount: "\(reviewsCount)", listenListCount: "\(listenListCount)")
                                
                            }
                            
                            NavigationLink(destination: ViewSettingsPage(user: user), isActive: $navigateToEditProfile) {
                                EmptyView()
                            }
                            
                            Spacer()
                        }
                        .padding()
                    } else {
                        ProgressView("Loading...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                    }
                    
                }
            }
            .navigationBarItems(trailing: isCurrentUser ? Button(action: {
                showActionSheet = true
            }) {
                Image(systemName: "gear")
            }: nil)
            .actionSheet(isPresented: $showActionSheet) {
                actionSheet
            }
            .alert(isPresented: $showLogoutAlert) {
                logoutAlert
            }
            .navigationBarTitle("\(user.username)", displayMode: .inline)
            .onAppear {
                fetchUserData()
            }
            .refreshable {
                fetchUserData()
            }
        }
    }
    
    private func fetchUserData() {
        guard let currentUserID = session.currentUserID else { return }
        isCurrentUser = (currentUserID == userID)
        
        let uidToFetch = isCurrentUser ? currentUserID : userID
        
        FirebaseUserDataManager().fetchUserData(uid: uidToFetch) { fetchedUser, error in
            if let error = error {
                print("Failed to  fetch user data: \(error.localizedDescription)")
            } else if let fetchedUser = fetchedUser {
                self.user = fetchedUser
                fetchFavoriteAlbums(albumKeys: fetchedUser.userAlbumFavorites ?? [])
                fetchUserConnectionsCount(uid: uidToFetch)
                fetchUserReviewsCount(uid: uidToFetch)
                fetchRecentActivity(uid: uidToFetch)
                fetchListenListCount(uid: uidToFetch)
                if !isCurrentUser {
                    checkIfFollowing(currentUserID: currentUserID, otherUserID: userID)
                }
                self.isLoading = false
            }
        }
    }
    
    private func fetchFavoriteAlbums(albumKeys: [String]) {
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
                self.favoriteAlbums = albums
            } else {
                print("Errors fetching albums: \(fetchErrors)")
            }
        }
    }
    
    private func fetchUserConnectionsCount(uid: String) {
        ProfilePageInfoRetrieval().fetchFollowingAndFollowersCount(userID: uid) { numFollowing, numFollowers, error in
            if let error = error {
                print("Failed to fetch following and followers count: \(error.localizedDescription)")
            } else {
                self.followingCount = String(numFollowing)
                self.followersCount = String(numFollowers)
            }
        }
    }
    
    private func fetchUserReviewsCount(uid: String) {
        ProfilePageInfoRetrieval().fetchAlbumReviewsWithTextCount(userID: uid) { totalCount, countWithText, error in
            if let error = error {
                print("Failed to fetch album reviews with text count: \(error.localizedDescription)")
            } else {
                self.allAlbumReviewsCount = String(totalCount)
                self.reviewsCount = String(countWithText)
            }
        }
    }
    
    private func fetchListenListCount(uid: String) {
        ProfilePageInfoRetrieval().fetchListenListCount(userID: uid) { count, error in
            if let error = error {
                print("Failed to fetch listen list count: \(error.localizedDescription)")
            } else if let count = count {
                self.listenListCount = String(count)
            }
        }
    }
    
    private func fetchRecentActivity(uid: String) {
        // calculate the date for ten weeks ago
        let tenWeeksAgo = Calendar.current.date(byAdding: .weekOfYear, value: -10, to: Date())
        
        FirebaseUserDataManager().fetchUserActivities(userID: uid) { fetchedUserActivities, error in
            if let error = error {
                print("Failed to fetch activities for current user: \(error.localizedDescription)")
            } else if let fetchedUserActivities = fetchedUserActivities {
                // Filter for activities from the last 10 weeks and with `albumReview` type
                let recentAlbumReviewActivities = fetchedUserActivities.filter { activity in
                    // Filter for the last 10 weeks
                    if let activityDate = ISO8601DateFormatter().date(from: activity.activityTimestamp) {
                        return activityDate >= tenWeeksAgo! && activity.activityType == .albumReview
                    }
                    return false
                }
                
                self.recentActivities = recentAlbumReviewActivities.reversed()
            }
        }
    }

    
    private func checkIfFollowing(currentUserID: String, otherUserID: String) {
        FirebaseUserDataManager().checkIfFollowing(currentUserID: currentUserID, otherUserID: otherUserID) { isFollowing in
            self.isFollowing = isFollowing
        }
    }
    
    private var actionSheet: ActionSheet {
        ActionSheet(title: Text("Options"), buttons: [
            .default(Text("Edit Profile")) {
                navigateToEditProfile = true
            },
            .destructive(Text("Log Out")) {
                showLogoutAlert = true
            },
            .cancel()
        ])
    }
    
    private var logoutAlert: Alert {
        Alert(
            title: Text("Log Out"),
            message: Text("Are you sure you want to log out?"),
            primaryButton: .destructive(Text("Log Out")) {
                session.signOut()
            },
            secondaryButton: .cancel()
        )
    }
    
}

struct ProfilePageFavoritesView: View {
    var favoriteAlbums: [Album]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("FAVORITES")
                .font(.subheadline)
                .foregroundColor(.white)
            
            HStack {
                ForEach(favoriteAlbums, id: \.firebaseKey) { favoriteAlbum in
                    NavigationLink(destination: ViewAlbumPage(albumKey: favoriteAlbum.firebaseKey)) {
                        if favoriteAlbum.coverImageURL != "", let url = URL(string: favoriteAlbum.coverImageURL) {
                            WebImage(url: url)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 70, height: 70)
                                .clipped()
                                .cornerRadius(10)
//                              .shadow(radius: 5)
                        } else {
                            PlaceholderAlbumCover(width: 70, height: 70)
                        }
                    }
                }
                Spacer()
            }
        }
    }
}

struct ProfilePageRecentActivityView: View {
    var user: User
    var activities: [Activity]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("RECENT ACTIVITY")
                .font(.subheadline)
                .foregroundColor(.white)
            HStack(spacing: 15) {
                ForEach(activities.prefix(4), id: \.activityID) { activity in
                    ProfilePageRecentActivityAlbumReviewView(activity: activity)
                }
                Spacer()
            }
            
            Divider().overlay(Color.gray)

            NavigationLink(destination: ViewUserMoreActivityPage(user: user)) {
                HStack {
                    Text("More activity")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                }
                .contentShape(Rectangle())
            }
            .padding(.bottom, 5)
            .buttonStyle(HighlightButtonStyle())

        }
    }
}

struct ProfilePageRecentActivityAlbumReviewView: View {
    var activity: Activity
    
    @EnvironmentObject var session: SessionStore
    @State private var user: User = User(userID: "", username: "sfjklfjksdfjksjkfskldfjkldfjfl", normalizedUsername: "", email: "", userProfilePictureURL: "", userBio: "")
    @State private var album: Album = Album(title: "", artistID: [], artistNames: [], genres: [], styles: [], year: 0, albumTracks: [], coverImageURL: "")
    @State private var albumReview: AlbumReview = AlbumReview(albumReviewID: "", userID: "", albumKey: "", rating: 0.0, reviewText: "", reviewTimestamp: "")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            NavigationLink(destination: ViewSpecificReviewPage(review: albumReview, user: user, album: album)) {
                if album.coverImageURL != "", let url = URL(string: album.coverImageURL) {
                    WebImage(url: url)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 70, height: 70)
                        .clipped()
                        .cornerRadius(10)
                } else {
                    PlaceholderAlbumCover(width: 70, height: 70)
                }
            }
            StarRatingView(rating: albumReview.rating, starSize: 10)

        }
        .onAppear() {
            fetchData()
        }
    }
    
    private func fetchData() {
        guard let currentUserID = session.currentUserID else {
            print("No current user ID found")
            return
        }
        
        fetchUser(userID: currentUserID)
        fetchAlbum(albumID: activity.albumID)
        fetchAlbumReview(reviewID: activity.albumReviewID ?? "", albumKey: activity.albumID)
    }
    
    private func fetchUser(userID: String) {
        FirebaseUserDataManager().fetchUserData(uid: userID) { fetchedUser, error in
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
    
    private func fetchAlbumReview(reviewID: String, albumKey: String) {
        FirebaseDataManager().fetchSpecificAlbumReview(albumKey: albumKey, reviewID: reviewID) { fetchedReview, error in
            if let error = error {
                print("Failed to fetch album review: \(error.localizedDescription)")
            } else if let fetchedReview = fetchedReview {
                self.albumReview = fetchedReview
            }
        }
    }
}

struct ProfilePageInfoLists: View {
    var user: User
    var allAlbumsCount: String
    var allReviewsCount: String
    var listenListCount: String
    
    var body: some View {
        VStack(alignment: .leading) {            
            // all albums with a rating
            NavigationLink(destination: ViewUserAlbumsPage(userID: user.userID)) {
                HStack {
                    Text("Albums")
                        .font(.subheadline).foregroundColor(.white)
                    Spacer()
                    Text("\(allAlbumsCount)")
                        .font(.subheadline).foregroundColor(.gray)
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                }
                .contentShape(Rectangle())
            }
            Divider().overlay(Color.white)

            // albums in listen list
            NavigationLink(destination: ViewUserListenListPage(userID: user.userID)) {
                HStack {
                    Text("Listen list")
                        .font(.subheadline).foregroundColor(.white)
                    Spacer()
                    Text("\(listenListCount)")
                        .font(.subheadline).foregroundColor(.gray)
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                }
                .contentShape(Rectangle())
            }
            Divider().overlay(Color.white)
        }
    }
}

struct ProfilePageQuickInfo: View {
    var user: User
    var followingCount: String
    var followersCount: String
    var reviewsCount: String
    
    var body: some View {
        //make them clickable
        HStack(spacing: 50) {
            VStack {
                NavigationLink(destination: ViewFollowingFollowersListPage(userID: user.userID, listType: "Following")) {
                    Text("\(followingCount)")
                        .font(.title)
                        .fontWeight(.bold)
                }
                Text("Following")
                    .font(.system(size: 15))
                    .fontWeight(.light)
            }
            VStack {
                NavigationLink(destination: ViewFollowingFollowersListPage(userID: user.userID, listType: "Followers")) {
                    Text("\(followersCount)")
                        .font(.title)
                        .fontWeight(.bold)
                }
                Text("Followers")
                    .font(.system(size: 15))
                    .fontWeight(.light)
            }
            VStack {
                NavigationLink(destination: ViewUserReviewsPage(user: user)) {
                    Text("\(reviewsCount)")
                        .font(.title)
                        .fontWeight(.bold)
                }
                Text("Reviews")
                    .font(.system(size: 15))
                    .fontWeight(.light)
            }
        }
    }
}

