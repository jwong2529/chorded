//
//  AlbumCarousel.swift
//  Chorded
//
//  Created by Janice Wong on 6/4/24.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI

struct AlbumCarousel: View {
    let albums: [Album]
    let albumCount: Int
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(albums.prefix(albumCount), id: \.firebaseKey) { album in
                    NavigationLink(destination: ViewAlbumPage(album: album)) {
                        WebImage(url: URL(string: album.coverImageURL))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 150, height: 150)
                            .clipped()
                            .cornerRadius(10)
                            .shadow(radius: 5)
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
