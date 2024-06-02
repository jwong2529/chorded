//
//  AppBackground.swift
//  MusicReviewApp
//
//  Created by Janice Wong on 5/25/24.
//

import Foundation
import SwiftUI

struct AppBackground: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [.blue, .black]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
    }
}
