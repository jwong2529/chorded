//
//  PlaceholderAlbumCover.swift
//  Chorded
//
//  Created by Janice Wong on 6/14/24.
//

import Foundation
import SwiftUI

struct PlaceholderAlbumCover: View {
    var width: CGFloat
    var height: CGFloat
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(width: width, height: height)
            .clipped()
            .cornerRadius(10)
            .shadow(radius: 5)
            
            Image(systemName: "music.note")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: width * 0.3, height: height * 0.3)
                .foregroundColor(.white)
        }
    }
}
