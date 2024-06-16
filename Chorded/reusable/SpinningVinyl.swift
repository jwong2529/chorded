//
//  SpinningVinyl.swift
//  Chorded
//
//  Created by Janice Wong on 6/16/24.
//

import Foundation
import SwiftUI

struct SpinningVinyl: View {
    @State private var rotation: Double = 0

    var body: some View {
        Image("vinyl")
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
}
