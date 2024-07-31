//
//  DropdownList.swift
//  Chorded
//
//  Created by Janice Wong on 6/9/24.
//

import Foundation
import SwiftUI


struct DropdownList: View {
    @Binding var selection: String?
    var state: DropdownListState = .bottom
    var options: [String]
    var maxWidth: CGFloat = 350
    
    @State private var showDropdown = false
    
    @SceneStorage("drop_down_zindex") private var index = 1000.0
    @State private var zindex = 1000.0
    
    var body: some View {
        VStack {
            VStack(spacing: 0) {
                if state == .top && showDropdown {
                    OptionsView()
                }
                
                HStack {
                    Text(selection == nil ? "Select" : selection!)
                        .foregroundColor(.white)
                    
                    Spacer(minLength: 0)
                    
                    Image(systemName: showDropdown ? "chevron.up" : "chevron.down")
                        .font(.title3)
                        .foregroundColor(.blue)
                        .rotationEffect(.degrees(showDropdown ? 180 : 0))
                }
                .padding(.horizontal, 15)
                .frame(height: 50)
                .onTapGesture {
                    index += 1
                    zindex = index
                    withAnimation(.easeInOut) {
                        showDropdown.toggle()
                    }
                }
                .zIndex(10)
                
                if state == .bottom && showDropdown {
                    OptionsView()
                }
            }
            .clipped()
            .zIndex(zindex)
            
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue.opacity(0.4)))
        }
    }
    
    func OptionsView() -> some View {
        VStack(spacing: 0) {
            ForEach(options, id: \.self) { option in
//                Button(action: {
//                    selection = option
//                    withAnimation(.easeInOut) {
//                        showDropdown.toggle()
//                    }
//                }) {
                HStack {
                    Text(option)
                    Spacer()
                }
                .foregroundStyle(Color.gray)
                .padding(.horizontal, 15)
                .frame(height: 40)
//                }
            }
        }
        .shadow(radius: 5)
        .transition(.opacity)
        .zIndex(1)
    }
}



enum DropdownListState {
    case top
    case bottom
}


//#Preview {
//    ViewAlbumPage()
//}

