//
//  ReviewCard.swift
//  Chorded
//
//  Created by Janice Wong on 8/1/24.
//

import Foundation
import SwiftUI

struct ReviewCard: View {
    var review: AlbumReview
    @State private var user: User?
        
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image("profilePic")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 20, height: 20)
                    .clipShape(Circle())
                
                VStack(alignment: .leading) {
                    Text(user?.username ?? "User")
                        .font(.subheadline)
                }
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
        FirebaseUserData().fetchUserData(uid: userID) { fetchedUser, error in
            if let error = error {
                print("Failed to fetch user data: \(error.localizedDescription)")
            } else if let fetchedUser = fetchedUser {
                self.user = fetchedUser
            }
        }
    }
}


