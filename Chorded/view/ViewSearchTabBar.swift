//
//  ViewSearchTabBar.swift
//  Chorded
//
//  Created by Janice Wong on 6/29/24.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI

struct ViewSearchTabBar: View {
    @Binding var selectedTab: Int
    private let tabs = ["Albums", "Artists","Users"]
//    var artists: [Artist]
//    var album: Album
    
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
                            .frame(maxWidth: 100)
                            .background(selectedTab == index ? Color.gray : Color.clear)
                            .cornerRadius(10)
                    }
                }
                Spacer()
            }
            .background(Color.clear)
            .cornerRadius(10)
            
//            if selectedTab == 0 {
//                if artists.isEmpty {
//                    Text("No artists available")
//                        .foregroundColor(.gray)
//                } else {
//                    ViewArtistsSectionTabBar(artists: artists)
//                }
//            } else if selectedTab == 1 {
//                ViewGenresSectionTabBar(album: album)
//            }
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}

#Preview {
    ViewSearchPage()
}
