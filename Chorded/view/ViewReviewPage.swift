//
//  ViewReviewPage.swift
//  Chorded
//
//  Created by Janice Wong on 6/9/24.
//

import Foundation
import SwiftUI

struct ViewReviewPage: View {
    let reviews: [AlbumReview]
    
//    init() {
//        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
//    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                ScrollView {
                    VStack {
                        if reviews.isEmpty {
                            Text("Be the first to leave a review!")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(reviews.reversed()) { review in
                                ReviewCard(review: review)
                                Divider().overlay(Color.white)
                            }
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.clear)
                }

            }
            .navigationTitle("Reviews")
        }
    }
    
}
