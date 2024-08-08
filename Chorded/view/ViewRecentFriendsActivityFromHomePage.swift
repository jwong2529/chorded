//
//  ViewRecentFriendsActivityFromHomePage.swift
//  Chorded
//
//  Created by Janice Wong on 8/6/24.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI

struct ViewRecentFriendsActivityFromHomePage: View {
    var activities: [Activity]
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                ScrollView() {
                    VStack {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 10) {
                            ForEach(activities, id: \.activityID) { activity in
                                HomePageRecentActivityAlbumsView(activity: activity)
                            }
                        }
                    }
                    .padding()
                    .navigationBarTitle("Recent From Friends", displayMode: .inline)
                }
            }
        }
    }
}
