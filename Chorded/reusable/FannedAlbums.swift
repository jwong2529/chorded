//
//  FannedAlbums.swift
//  Chorded
//
//  Created by Janice Wong on 6/16/24.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI

struct FannedAlbums: View {
    
    var albums: [Album] = []
    
    var body: some View {
        if albums.count >= 3 {
            ForEach(albums.prefix(3).indices, id: \.self) { index in
                if albums[index].coverImageURL != "", let url = URL(string: albums[index].coverImageURL) {
                    WebImage(url: url)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
//                            .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipped()
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .rotationEffect(.degrees(Double(index) * 10 - 10))
                        .offset(x: CGFloat(index - 1) * -30, y: 0)
                } else {
                    PlaceholderAlbumCover(width: 100, height: 100)
                }
            }
        }
    }
}

//#Preview {
//    ViewHomePage()
//}
