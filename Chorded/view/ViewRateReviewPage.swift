//
//  ViewRateReviewPage.swift
//  MusicReviewApp
//
//  Created by Janice Wong on 5/25/24.
//

import Foundation
import SwiftUI

struct ViewRateReviewPage: View {
    init() {
//        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
            }
            .navigationTitle("Add a review")
        }
    }
}
