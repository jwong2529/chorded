//
//  MiniTabBar.swift
//  Chorded
//
//  Created by Janice Wong on 6/9/24.
//

import Foundation
import SwiftUI

struct ViewAlbumPageMiniBar: View {
    @State private var selectedTab = 0
    private let tabs = ["Artist", "Genres"]
    var artists: [Artist]
    var album: Album
    
    var body: some View {
        VStack {
            HStack {
                ForEach(0..<tabs.count) { index in
                    Button(action: {
                        withAnimation(.easeOut) {
                            selectedTab = index
                        }
                    }) {
                        Text(tabs[index])
                            .foregroundColor(selectedTab == index ? .white : .gray)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(selectedTab == index ? Color.gray : Color.clear)
                            .cornerRadius(10)
                    }
                }
            }
            .background(Color.black.opacity(0.8))
            .cornerRadius(10)
            
            if selectedTab == 0 {
                if artists.isEmpty {
                    Text("No artists available")
                        .foregroundColor(.gray)
                } else {
                    ViewArtistsSectionTabBar(artists: artists)
                }
            } else if selectedTab == 1 {
                ViewGenresSectionTabBar(album: album)
            }
        }
        .padding()
    }
}

//#Preview {
//    ViewAlbumPage()
//}

