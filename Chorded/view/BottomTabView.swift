//
//  BottomTabView.swift
//  MusicReviewApp
//
//  Created by Janice Wong on 5/25/24.
//

import Foundation
import SwiftUI

struct BottomTabView: View {
    @EnvironmentObject var session: SessionStore
    @State private var selectedItem = 0
//    @State private var oldSelectedItem = 0
    @State private var showRateReviewPage = false
    
    init() {
//        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
    }
    
    var body: some View {
        ZStack {
            ViewSearchPage()
            VStack {
                TabView(selection: $selectedItem) {
                    ViewHomePage()
                        .tabItem {
                            Image(systemName: "house.fill")
                        }
                        .tag(0)
                    ViewSearchPage()
                        .tabItem {
                            Image(systemName: "magnifyingglass")
                        }
                        .tag(1)
                    ViewSearchPage()    // search page is the sheet behind review modal
                        .tabItem {
                            Image(systemName: "square.and.pencil")
                        }
                        .tag(2)
                    ViewActivitiesPage()
                        .tabItem {
                            Image(systemName: "bolt")
                        }
                        .tag(3)
                    ViewProfilePage(userID: session.currentUserID ?? "")
                        .tabItem {
                            Image(systemName: "person.fill")
                        }
                        .tag(4)
                }
                .onChange(of: selectedItem) { newValue in
                    if newValue == 2 {
                        self.showRateReviewPage = true
                    }
                }
                .sheet(isPresented: $showRateReviewPage, onDismiss: {
                    self.selectedItem = 1 //when dismissed, stays on search page
                }) {
                    ViewRateReviewPage(showRateReviewPage: self.$showRateReviewPage)
                }
            }
        }
        
    }
}
