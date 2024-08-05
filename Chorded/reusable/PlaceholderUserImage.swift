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
        Image("profilePic")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: width, height: height)
            .clipShape(Circle())
    }
}


