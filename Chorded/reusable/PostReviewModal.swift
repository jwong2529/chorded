//
//  PostReviewModal.swift
//  Chorded
//
//  Created by Janice Wong on 7/28/24.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI

struct PostReviewModal: View {
    @Binding var showModal: Bool
    @State private var reviewText: String = "Write your review here..."
    @State private var rating: Double = 0.0
    @State private var addToListenList: Bool = false
    @State private var starStates: [StarState] = Array(repeating: .empty, count: 5)
//    @FocusState private var isTextEditorFocused: Bool
    
    var album: Album
    
    var body: some View {
        NavigationView {
            ZStack {
                AppBackground()
                
                ScrollView {
                    VStack (spacing: 16) {
                        
                        //Album details
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                if album.coverImageURL != "", let url = URL(string: album.coverImageURL) {
                                    WebImage(url: url)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 40, height: 40)
                                        .clipped()
                                        .cornerRadius(10)
                                        .shadow(color: .blue, radius: 5)
                                } else {
                                    PlaceholderAlbumCover(width: 40, height: 40)
                                }
                                VStack(alignment: .leading) {
                                    Text(album.title)
                                        .foregroundColor(.white)
                                    Text(String(album.year))
                                        .foregroundColor(.gray)
                                }
                            }
                            Divider().overlay(Color.white)
                            
                            Toggle("Add to listen list", isOn: $addToListenList)
                                .padding(.top, 8)
                        }
                        .padding()
                        .background(.gray.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.horizontal)
                                            
                        //Review date
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Date")
                                .font(.headline)
                            Text("\(Date(), formatter: dateFormatter)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Divider().overlay(Color.white)
                        }
                        .padding(.horizontal)
                        
                        //Rating section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Rate")
                                .font(.headline)
                            HStack {
                                ForEach(0..<5) { index in
                                    StarView(state: self.$starStates[index])
                                        .onTapGesture {
                                            self.toggleStar(at: index)
                                        }
                                }
                            }
                            Divider().overlay(Color.white)
                        }
                        .padding(.horizontal)
                        
                        //Review text section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Review")
                                .font(.headline)
                            TextEditor(text: $reviewText)
//                                .focused($isTextEditorFocused)
                                .frame(minHeight: 200)
                                .scrollContentBackground(.hidden)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .lineSpacing(5)
                                .multilineTextAlignment(.leading)
                            
                                .onAppear {
                                    //remove the placeholder text when keyboard appears
                                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (noti) in
                                        withAnimation {
                                            if self.reviewText == "Write your review here..." {
                                                self.reviewText = ""
                                            }
                                        }
                                    }
                                    
                                    //put back the placeholder text if the user dismisses the keyboard without adding any text
                                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (noti) in
                                        withAnimation {
                                            if self.reviewText == "" {
                                                self.reviewText = "Write your review here..."
                                            }
                                        }
                                    }
                                }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                        
                        Spacer()
                        
                            
                    }
                    .navigationBarTitle("Post a Review", displayMode: .inline)
                    .navigationBarItems(leading: Button(action: {
                        self.showModal = false
                    }) {
                        Text("Cancel")
                    })
                    .navigationBarItems(trailing: Button(action: {
                        //Handle review submission
                        self.showModal = false
                    }) {
                        Text("Save")
                            .padding(3)
                            .foregroundColor(Color.green)
                    })
                    .onAppear {
                        self.updateRating()
                    }
//                    .background(Color.clear) // Add clear background to allow tap detection
//                    .onTapGesture {
//                        hideKeyboard()
//                    }

                }
                
            }
            
        }
    }
    
    private func toggleStar(at index: Int) {
        
        switch starStates[index] {
        case .empty:
            starStates[index] = .full
        case .half:
            starStates[index] = .empty
        case .full:
            starStates[index] = .half
        }
        
        // Fill stars up to the clicked index
        for i in 0..<index {
            starStates[i] = .full
        }
        // Empty stars after the clicked index
        for i in (index + 1)..<starStates.count {
            starStates[i] = .empty
        }
        
        updateRating()
    }
    
    private func updateRating() {
        rating = starStates.reduce(0.0) { $0 + $1.rawValue }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

enum StarState: Double {
    case empty = 0.0
    case half = 0.5
    case full = 1.0
}

struct StarView: View {
    @Binding var state: StarState
    
    var body: some View {
        switch state {
        case .empty:
            Image(systemName: "star")
                .resizable()
                .frame(width: 25, height: 25)
                .foregroundColor(.gray)
        case .half:
            Image(systemName: "star.leadinghalf.filled")
                .resizable()
                .frame(width: 25, height: 25)
                .foregroundColor(.yellow)
        case .full:
            Image(systemName: "star.fill")
                .resizable()
                .frame(width: 25, height: 25)
                .foregroundColor(.yellow)
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()
