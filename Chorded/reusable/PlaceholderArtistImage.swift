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
        ZStack {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: width, height: height)
            
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: width * 0.7, height: height * 0.7)
                .foregroundColor(.gray)
        }
    }
}
