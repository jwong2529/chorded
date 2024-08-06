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
    @State private var following: [String] = []
    @State private var followers: [String] = []
    @State private var reviews: [AlbumReview] = []
    @State private var isFollowing: Bool = false
    
    // for logging out a user
    @State private var showActionSheet = false
    @State private var showLogoutAlert = false
    @State private var navigateToEditProfile = false
    
//    init() {
//        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
//    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                
                ScrollView {
                    VStack {
                        
                        VStack {
                            if let url = URL(string: user.userProfilePictureURL) {
                                WebImage(url: url)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .shadow(color: .blue, radius: 5)
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .padding(.top)
                            } else {
                                PlaceholderUserImage(width: 120, height: 120)
                                    .shadow(color: .blue, radius: 5)
                                    .padding(.top)
                            }
                            
                            if !isCurrentUser {
                                Button(action: {
                                    if isFollowing {
                                        FirebaseUserData().unfollowUser(currentUserID: session.currentUserID ?? "", unfollowedUserID: userID)
                                    } else {
                                        FirebaseUserData().followUser(currentUserID: session.currentUserID ?? "", followedUserID: userID)
                                    }
                                    isFollowing.toggle()
                                }) {
                                    Text(isFollowing ? "Unfollow": "Follow")
//                                        .padding()
                                        .padding(.vertical, 5)
                                        .padding(.horizontal, 20)
                                        .background(isFollowing ? Color.blue.opacity(0.3) : Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                                .padding(5)
                            }
                            
                            HStack(spacing: 50) {
                                VStack {
                                    Text("\(following.count)")
                                        .font(.title)
                                        .fontWeight(.bold)
                                    Text("Following")
                                        .font(.system(size: 15))
                                        .fontWeight(.light)
                                }
                                VStack {
                                    Text("\(followers.count)")
                                        .font(.title)
                                        .fontWeight(.bold)
                                    Text("Followers")
                                        .font(.system(size: 15))
                                        .fontWeight(.light)
                                }
                                VStack {
                                    Text("\(reviews.count)")
                                        .font(.title)
                                        .fontWeight(.bold)
                                    Text("Reviews")
                                        .font(.system(size: 15))
                                        .fontWeight(.light)
                                }
                            }
                            .padding(.top, 1)
                        }
                        
                        Spacer()
                        
                        NavigationLink(destination: ViewEditProfilePage(), isActive: $navigateToEditProfile) {
                            EmptyView()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
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
        
        FirebaseUserData().fetchUserData(uid: uidToFetch) { fetchedUser, error in
            if let error = error {
                print("Failed to  fetch user data: \(error.localizedDescription)")
            } else if let fetchedUser = fetchedUser {
                self.user = fetchedUser
                fetchUserConnections(uid: uidToFetch)
                fetchUserReviews(uid: uidToFetch)
                if !isCurrentUser {
                    checkIfFollowing(currentUserID: currentUserID, otherUserID: userID)
                }
            }
        }
    }
    
    private func fetchUserConnections(uid: String) {
        FirebaseUserData().fetchUserConnections(uid: uid) { followingList, followersList in
            self.following = followingList
            self.followers = followersList
        }
    }
    
    private func fetchUserReviews(uid: String) {
        FirebaseUserData().fetchUserReviews(uid: uid) { fetchedReviews, error in
            if let error = error {
                print("Failed to fetch user's reviews: \(error.localizedDescription)")
            } else if let fetchedReviews = fetchedReviews {
                self.reviews = fetchedReviews
            }
        }
    }
    
    private func checkIfFollowing(currentUserID: String, otherUserID: String) {
        FirebaseUserData().checkIfFollowing(currentUserID: currentUserID, otherUserID: otherUserID) { isFollowing in
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

//#Preview {
//    ViewProfilePage().environmentObject(SessionStore())
//}

