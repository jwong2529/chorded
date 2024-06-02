//
//  AlbumCarousel.swift
//  MusicReviewApp
//
//  Created by Janice Wong on 5/25/24.
//

import Foundation
import SwiftUI

struct AlbumCarousel: View {
    let albums: [Album]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(albums.prefix(10), id: \.discogsID) { album in
                    VStack {
//                        if let url = album.coverImageURL {
//                            AsyncImage(url: url) { image in
//                                image.resizable()
//                                    .aspectRatio(contentMode: .fill)
//                                    .frame(width: 150, height: 150)
//                                    .clipped()
//                                    .cornerRadius(10)
//                                    .shadow(radius: 5)
//                            } placeholder: {
//                                ProgressView()
//                                    .frame(width: 150, height: 150)
//                            }
//                        } else {
//                            Color.gray
//                                .frame(width: 150, height: 150)
//                        }
//                        Text(album.title)
//                            .foregroundColor(.white)
//                            .font(.caption)
//                            .multilineTextAlignment(.center)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    ViewHomePage()
}
