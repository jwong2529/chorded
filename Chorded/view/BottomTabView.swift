//
//  BottomTabView.swift
//  MusicReviewApp
//
//  Created by Janice Wong on 5/25/24.
//

import Foundation
import SwiftUI

struct BottomTabView: View {
    
    init() {
      UITabBar.appearance().unselectedItemTintColor = UIColor.gray
//        UITabBar.appearance().backgroundColor = UIColor.gray
    }
    
    var body: some View {
        TabView {
            ViewHomePage()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            ViewSearchPage()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            ViewRateReviewPage()
                .tabItem {
                    Label("Review", systemImage: "square.and.pencil")
                }
            ViewDiscoverPage()
                .tabItem {
                    Label("Discover", systemImage: "headphones")
                }
            ViewProfilePage()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}

#Preview {
    BottomTabView()
}
