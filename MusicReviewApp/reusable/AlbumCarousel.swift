//
//  AlbumCarousel.swift
//  MusicReviewApp
//
//  Created by Janice Wong on 5/25/24.
//

import Foundation
import SwiftUI

struct AlbumCarousel: View {
    let albumImages: [String]
    let count: Int
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(0..<min(count, albumImages.count), id: \.self) { albumImage in
                    Image(albumImages[albumImage])
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 150, height: 150)
                        .clipped()
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    ViewHomePage()
}
