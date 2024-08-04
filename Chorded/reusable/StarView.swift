//
//  StarView.swift
//  Chorded
//
//  Created by Janice Wong on 8/2/24.
//

import Foundation
import SwiftUI

enum StarState: Double {
    case empty = 0.0
    case half = 0.5
    case full = 1.0
}

struct StarView: View {
    @Binding var state: StarState
    var starSize: CGFloat
    
    var body: some View {
        switch state {
        case .empty:
            Image(systemName: "star")
                .resizable()
                .frame(width: starSize, height: starSize)
                .foregroundColor(.gray)
        case .half:
            Image(systemName: "star.leadinghalf.filled")
                .resizable()
                .frame(width: starSize, height: starSize)
                .foregroundColor(.yellow)
        case .full:
            Image(systemName: "star.fill")
                .resizable()
                .frame(width: starSize, height: starSize)
                .foregroundColor(.yellow)
        }
    }
}

struct StarRatingView: View {
    var rating: Double
    var starSize: CGFloat = 15
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5) { index in
                StarView(state: .constant(self.starState(for: index)), starSize: starSize)
            }
        }
    }
    
    private func starState(for index: Int) -> StarState {
        let starValue = Double(index) + 0.5
        
        if rating >= Double(index + 1) {
            return .full
        } else if rating >= starValue {
            return .half
        } else {
            return .empty
        }
    }
}


