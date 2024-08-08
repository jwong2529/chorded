//
//  ViewFollowingFollowersListPage.swift
//  Chorded
//
//  Created by Janice Wong on 8/6/24.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI

struct ViewFollowingFollowersListPage: View {
    var userID: String
    var listType: String //following, followers
    
    @State private var userList: [User] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                ScrollView() {
                    VStack(alignment: .leading) {
                        ForEach(userList, id: \.userID) { user in
                            NavigationLink(destination: ViewProfilePage(userID: user.userID)) {
                                HStack {
                                    if let url = URL(string: user.userProfilePictureURL) {
                                        WebImage(url: url)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 20, height: 20)
                                            .clipShape(Circle())
                                    } else {
                                        PlaceholderUserImage(width: 20, height: 20)
                                    }
                                    VStack(alignment: .leading) {
                                        Text(user.username)
                                            .font(.subheadline)
                                    }
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Divider().overlay(Color.white)
                        }
                    }
                    .padding()
                    .navigationBarTitle("\(listType)", displayMode: .inline)
                    .onAppear() {
                        fetchUsers()
                    }
                }
            }
        }
    }
    
    private func fetchUsers() {
        if listType == "Following" {
            FirebaseUserData().fetchFollowing(uid: userID) { followingList in
                var followingListUsers: [User] = []
                let fetchGroup = DispatchGroup()
                
                for followingListID in followingList {
                    fetchGroup.enter()
                    FirebaseUserData().fetchUserData(uid: followingListID) { user, error in
                        if let error = error {
                            print("Failed to fetch user \(followingListID): \(error.localizedDescription)")
                        } else if let user = user {
                            followingListUsers.append(user)
                        }
                        fetchGroup.leave()
                    }
                }
                fetchGroup.notify(queue: .main) {
                    self.userList = followingListUsers
                }
            }
        } else if listType == "Followers" {
            FirebaseUserData().fetchFollowers(uid: userID) { followersList in
                var followersListUsers: [User] = []
                let fetchGroup = DispatchGroup()
                
                for followersListID in followersList {
                    fetchGroup.enter()
                    FirebaseUserData().fetchUserData(uid: followersListID) { user, error in
                        if let error = error {
                            print("Failed to fetch user \(followersListID): \(error.localizedDescription)")
                        } else if let user = user {
                            followersListUsers.append(user)
                        }
                        fetchGroup.leave()
                    }
                }
                fetchGroup.notify(queue: .main) {
                    self.userList = followersListUsers
                }
            }
        }
                        
    }
}
