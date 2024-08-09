//
//  PlaceholderUserImage.swift
//  Chorded
//
//  Created by Janice Wong on 8/4/24.
//

import Foundation
import SwiftUI

struct PlaceholderUserImage: View {
    var width: CGFloat
    var height: CGFloat
    
    var body: some View {
        ZStack {
            Color.white
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing)
            .mask(Image(systemName: "person.crop.circle.fill")
                  .resizable()
                  .frame(width: width, height: height)
                  .aspectRatio(contentMode: .fit))
        }
        .frame(width: width, height: height)
        .clipShape(Circle())
    }
}
