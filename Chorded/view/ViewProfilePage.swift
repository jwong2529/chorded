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
    
    init() {
//        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                    
                    ScrollView{
                        
                        VStack{
                            HStack {
                                Spacer()
                                Button(action: {
                                    session.signOut()
                                }) {
                                    Text("Logout")
                                        .padding(.top, -5)
                                        .padding(5)
                                        .foregroundColor(.white)
                                        .background(Color.red)
                                        .cornerRadius(8)
                                }
                                .padding()
                            }
                            Spacer()
                            
                            VStack(spacing: 16) {
                                Image("profilePic")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .shadow(color: .blue, radius: 5)
                                    .padding(.top, -10)
                                
                                if let user = session.currentUser {
                                    Text(user.username)
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(.top, -10)
                                    
                                    HStack(spacing: 40) {
                                        VStack {
                                            Text("\(session.userConnections?.following.count ?? 0)")
                                                .font(.title)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                            Text("Following")
                                                .font(.system(size: 15))
                                                .fontWeight(.light)
                                                .foregroundColor(.white)
                                        }
                                        VStack {
                                            Text("\(session.userConnections?.followers.count ?? 0)")
                                                .font(.title)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                            Text("Followers")
                                                .font(.system(size: 15))
                                                .fontWeight(.light)
                                                .foregroundColor(.white)
                                        }
                                        VStack {
                                            Text("\(session.userReviews?.albumReviews.count ?? 0)")
                                                .font(.title)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                            Text("Reviews")
                                                .font(.system(size: 15))
                                                .fontWeight(.light)
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .padding(.top, 10)
                                }
                                
                                
                            }
                            Spacer()
                            
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        
                        
                        
                        Spacer()
                        
                    }
            
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ViewProfilePage()
}
