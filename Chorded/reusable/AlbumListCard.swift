//
//  AlbumListCard.swift
//  Chorded
//
//  Created by Janice Wong on 6/16/24.
//

import Foundation
import SwiftUI

struct AlbumListCard: View {
    var title: String
    var gradientColors: [Color]
    var design: String
    var albums: [Album] = []

    var body: some View {
        VStack {
            
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .default))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(.top, 20)
                .padding(.bottom, 10)
                        
            if design == "fanned" {
                HStack {
                    Spacer()
                    FannedAlbums(albums: albums)
                    Spacer()
                }
            } else if design == "vinyl" {
                SpinningVinyl()
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .topLeading, endPoint: .bottomTrailing))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}

//#Preview {
//    ViewHomePage()
//}
