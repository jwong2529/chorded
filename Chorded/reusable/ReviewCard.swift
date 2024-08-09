//
//  ReviewCard.swift
//  Chorded
//
//  Created by Janice Wong on 8/1/24.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI

struct ReviewCard: View {
    var review: AlbumReview
    @State private var user: User = User(userID: "", username: "", normalizedUsername: "", email: "", userProfilePictureURL: "", userBio: "")
        
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
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
                
                Spacer()
                let reviewDate = ISO8601DateFormatter().date(from: review.reviewTimestamp) ?? Date()
                Text(FixStrings().timeAgoSinceDate(reviewDate))
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            StarRatingView(rating: review.rating)
                .padding(.bottom, 4)
            Text(review.reviewText)
                .font(.footnote)
        }
        .onAppear() {
            fetchUserData(userID: review.userID)
        }
    }
    
    
    private func fetchUserData(userID: String) {
        FirebaseUserDataManager().fetchUserData(uid: userID) { fetchedUser, error in
            if let error = error {
                print("Failed to fetch user data: \(error.localizedDescription)")
            } else if let fetchedUser = fetchedUser {
                self.user = fetchedUser
            }
        }
    }
}


