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
    @State private var reviewText: String = ""
    @State private var placeholderText: String = "Write your review here..."
    @State private var rating: Double = 0.0
    @State private var addToListenList: Bool = false
    @State private var starStates: [StarState] = Array(repeating: .empty, count: 5)
    var starSize: CGFloat = 25
    @EnvironmentObject var session: SessionStore
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
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
                                    StarView(state: self.$starStates[index], starSize: starSize)
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
                            ZStack {
                                if reviewText.isEmpty {
                                    TextEditor(text: $placeholderText)
                                        .disabled(true)
                                        .frame(minHeight: 200)
                                        .scrollContentBackground(.hidden)
                                        .foregroundColor(.white)
                                        .padding()
//                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(8)
                                        .lineSpacing(5)
                                        .multilineTextAlignment(.leading)
                                }
                                TextEditor(text: $reviewText)
                                    .frame(minHeight: 200)
                                    .scrollContentBackground(.hidden)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                    .lineSpacing(5)
                                    .multilineTextAlignment(.leading)
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
                        saveReview()
                    }) {
                        Text("Save")
                            .padding(3)
                            .foregroundColor(Color.green)
                    })
                    .onAppear {
                        self.updateRating()
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text(""), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                    }

                }
                
            }
            
        }
    }
    
    private func saveReview() {
        guard let userID = session.currentUserID else {
            print("No current user ID found")
            return
        }
        
        // user must submit a rating if they've written a review
        if reviewText != "" && rating <= 0 {
            alertMessage = "Rating is required to submit the review"
            showAlert = true
            return
        }
        
        // ensure review text does not exceed 1000 characters
        if reviewText.count > 1000 {
            alertMessage = "Review must not exceed 1000 characters"
            showAlert = true
            return
        }
        
        let reviewID = UUID().uuidString
        let timestamp = ISO8601DateFormatter().string(from: Date())
        
        let review = AlbumReview(
            id: reviewID,
            userID: userID,
            albumKey: album.firebaseKey,
            rating: rating,
            reviewText: reviewText,
            timestamp: timestamp
        )
        
        // post review if rating is non empty
         if review.rating != 0 {
            FirebaseDataManager().postAlbumReview(albumID: album.firebaseKey, review: review) { error in
                if let error = error {
                    print("Error posting review: \(error.localizedDescription)")
                } else {
                    alertMessage = "Saved review!"
                    showAlert = true
                    self.showModal = false
                }
            }
        } else {
            self.showModal = false
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

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()


