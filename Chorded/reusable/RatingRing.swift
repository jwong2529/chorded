//
//  RatingRing.swift
//  Chorded
//
//  Created by Janice Wong on 6/8/24.
//

import Foundation
import SwiftUI

struct RatingRing: View {
    @Binding var rating: CGFloat

    var body: some View {
            ZStack {
                Circle()
                    .stroke(Color(.cyan).opacity(0.3), lineWidth: 8)
                
                Circle()
                    .trim(from: 0.0, to: rating / 5)
                    .stroke(Color(.cyan), style: StrokeStyle(lineWidth: 8, lineCap: .round, lineJoin: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 2.0), value: rating / 5)
                Text("\(rating, specifier: "%.1f")")
                    .font(.headline)
                    .foregroundColor(.white)
            }
//            .onAppear {
//                rating = 3.7
//            }
        }
}

//#Preview {
//    ViewAlbumPage()
//}
