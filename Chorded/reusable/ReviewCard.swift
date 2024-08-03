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
                let reviewDate = ISO8601DateFormatter().date(from: review.timestamp) ?? Date()
                Text(timeAgoSinceDate(reviewDate))
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
    
    private func timeAgoSinceDate(_ date: Date, currentDate: Date = Date()) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute, .hour, .day, .weekOfYear, .year], from: date, to: currentDate)
        
        // Compute the total time difference in minutes
        let totalMinutes = (components.year ?? 0) * 525600 +
                            (components.weekOfYear ?? 0) * 10080 +
                            (components.day ?? 0) * 1440 +
                            (components.hour ?? 0) * 60 +
                            (components.minute ?? 0)
        
        // Determine the appropriate unit based on the total minutes
        if totalMinutes < 60 {
            return "\(components.minute ?? 0)m"
        } else if totalMinutes < 1440 {
            return "\(components.hour ?? 0)h"
        } else if totalMinutes < 10080 {
            return "\(components.day ?? 0)d"
        } else if totalMinutes < 525600 {
            return "\(components.weekOfYear ?? 0)wk"
        } else {
            return "\(components.year ?? 0)yr"
        }
    }

    
    private func fetchUserData(userID: String) {
        FirebaseUserData.shared.fetchUserData(uid: userID) { fetchedUser, error in
            if let error = error {
                print("Failed to fetch user data: \(error.localizedDescription)")
            } else if let fetchedUser = fetchedUser {
                self.user = fetchedUser
            }
        }
    }
}


