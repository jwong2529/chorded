//
//  PlaceholderArtistImage.swift
//  Chorded
//
//  Created by Janice Wong on 6/14/24.
//

import Foundation
import SwiftUI

struct PlaceholderArtistImage: View {
    var width: CGFloat
    var height: CGFloat
    
    var body: some View {
        Image(systemName: "person.crop.circle.fill")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: width, height: height)
            .clipShape(Circle())
    }
}
