//
//  ClickableArtistsView.swift
//  Chorded
//
//  Created by Janice Wong on 6/13/24.
//

import Foundation
import SwiftUI

struct ClickableArtistsView: View {
    var artists: [Artist]
    
    var body: some View {
        HStack(spacing: 5) {
            ForEach(Array(artists.enumerated()), id: \.element.id) { index, artist in
                NavigationLink(destination: ViewArtistPage(artistID: artist.id)) {
                    Text(artist.name)
                        .foregroundColor(.blue)
                        .underline()
                }
                if index < artists.count - 1 {
                    Text(",")
                        .foregroundColor(.white)  
                }
            }
        }
    }
}
