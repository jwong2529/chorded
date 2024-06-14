//
//  ViewArtistsSectionTabBar.swift
//  Chorded
//
//  Created by Janice Wong on 6/12/24.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI

struct ViewArtistsSectionTabBar: View {
    var artists: [Artist]
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(artists) { artist in
                NavigationLink(destination: ViewArtistPage(artist: artist)) {
                    HStack {
                        if artist.imageURL != "", let url = URL(string: artist.imageURL) {
                            WebImage(url: url)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 35, height: 35)
                                .clipShape(Circle())
                                .padding(.trailing, 10)
                        } else {
                            PlaceholderArtistImage(width: 35, height: 35)
                        }
                        Text(artist.name)
                            .foregroundColor(.gray)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.blue)
                    }
                    .contentShape(Rectangle())
                    .padding(.vertical, 5)
                }
            }
        }
        .padding(.top)
        .padding(.bottom)
    }
}

