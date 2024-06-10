//
//  ViewReviewPage.swift
//  Chorded
//
//  Created by Janice Wong on 6/9/24.
//

import Foundation
import SwiftUI

struct ViewReviewPage: View {
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
            }
            .navigationTitle("Reviews")
        }
    }
}
