//
//  ViewProfile.swift
//  MusicReviewApp
//
//  Created by Janice Wong on 5/25/24.
//

import Foundation
import SwiftUI

struct ViewProfilePage: View {
    @EnvironmentObject var session: SessionStore
    @State private var user: User? = nil
    @State private var connections: UserConnections? = nil
    @State private var reviews: UserReviews? = nil
    @State private var listenList: UserListenList? = nil
    
    init() {
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                
                ScrollView {
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                session.signOut()
                            }) {
                                Text("Logout")
                                    .padding(5)
                                    .foregroundColor(.white)
                                    .background(Color.red)
                                    .cornerRadius(8)
                            }
                        }
                        .padding()
                        
                        VStack {
                            Image("profilePic")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .shadow(color: .blue, radius: 5)
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .padding(.top, -20)
                            
                            Text(user?.username ?? "")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            HStack(spacing: 50) {
                                VStack {
                                    Text("\(connections?.following?.count ?? 0)")
                                        .font(.title)
                                        .fontWeight(.bold)
                                    Text("Following")
                                        .font(.system(size: 15))
                                        .fontWeight(.light)
                                }
                                VStack {
                                    Text("\(connections?.followers?.count ?? 0)")
                                        .font(.title)
                                        .fontWeight(.bold)
                                    Text("Followers")
                                        .font(.system(size: 15))
                                        .fontWeight(.light)
                                }
                                VStack {
                                    Text("\(reviews?.albumReviews?.count ?? 0)")
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
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
                
            }
            .navigationBarTitle("Profile", displayMode: .inline)
            .onAppear {
                if session.isLoggedIn {
                    fetchUserData()
                }
            }
        }
    }
    
    private func fetchUserData() {
        guard let userID = session.currentUserID else { return }
        
        print("Fetching data for userID: \(userID)")
        
        FirebaseUserData.shared.fetchUserData(uid: userID) { fetchedUser, error in
            if let error = error {
                print("Failed to fetch user data: \(error.localizedDescription)")
            } else if let fetchedUser = fetchedUser {
                self.user = fetchedUser
                print("Fetched user: \(fetchedUser)")
            }
        }
        
        FirebaseUserData.shared.fetchUserConnections(uid: userID) { fetchedConnections, error in
            if let error = error {
                print("Failed to fetch user connections: \(error.localizedDescription)")
            } else if let fetchedConnections = fetchedConnections {
                self.connections = fetchedConnections
                print("Fetched user connections: \(fetchedConnections)")
            }
        }
        
        FirebaseUserData.shared.fetchUserReviews(uid: userID) { fetchedReviews, error in
            if let error = error {
                print("Failed to fetch user reviews: \(error.localizedDescription)")
            } else if let fetchedReviews = fetchedReviews {
                self.reviews = fetchedReviews
                print("Fetched reviews: \(fetchedReviews)")
            }
        }
        
        FirebaseUserData.shared.fetchUserListenList(uid: userID) { fetchedListenList, error in
            if let error = error {
                print("Failed to fetch user listen list: \(error.localizedDescription)")
            } else if let fetchedListenList = fetchedListenList {
                self.listenList = fetchedListenList
                print("Fetched user listen list: \(fetchedListenList)")
            }
        }
    }
}

//#Preview {
//    ViewProfilePage().environmentObject(SessionStore())
//}
