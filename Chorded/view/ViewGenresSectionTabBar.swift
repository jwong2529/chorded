//
//  ViewGenresSectionTabBar.swift
//  Chorded
//
//  Created by Janice Wong on 6/13/24.
//

import Foundation
import SwiftUI

struct ViewGenresSectionTabBar: View {
    var album: Album
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let genres = album.genres, !genres.isEmpty {
                Text("Genres")
                    .font(.headline)
                ForEach(genres, id: \.self) { genre in
                    Text(genre)
                        .foregroundColor(.gray)
                }
            }
            if let styles = album.styles, !styles.isEmpty {
                Text("Styles")
                    .font(.headline)
                    .padding(.top, 10)
                ForEach(styles, id: \.self) { style in
                    Text(style)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.top)
        .padding(.bottom)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
