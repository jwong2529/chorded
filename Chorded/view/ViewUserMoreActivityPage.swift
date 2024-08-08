//
//  ViewUserMoreActivityPage.swift
//  Chorded
//
//  Created by Janice Wong on 8/6/24.
//

import Foundation
import SwiftUI

struct ViewUserMoreActivityPage: View {
    var user: User
    var activities: [Activity] = []
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
        }
        .navigationBarTitle("Activity", displayMode: .inline)
    }
}
