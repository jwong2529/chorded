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
    @State private var originalReviewText: String = ""
    @State private var placeholderText: String = "Write your review here..."
    @State private var rating: Double = 0.0
    @State private var originalRating: Double = 0.0
    @State private var reviewID: String = ""
    @State private var listenList: Bool = false
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
                        
                        // album details
                        VStack(alignment: .leading, spacing: 8) {
                            HStack() {
                                if album.coverImageURL != "", let url = URL(string: album.coverImageURL) {
                                    WebImage(url: url)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 40, height: 40)
                                        .clipped()
                                        .cornerRadius(10)
                                } else {
                                    PlaceholderAlbumCover(width: 40, height: 40)
                                }
                                VStack(alignment: .leading) {
                                    Text(album.title)
                                        .foregroundColor(.white)
                                    Text(String(album.year))
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)

                            
                            // only allow people to add to listen list if it hasn't been rated yet
                            if self.rating == 0.0 {
                                Divider().overlay(Color.white)
                                
                                Toggle("Add to listen list", isOn: $listenList)
                                    .padding(.top, 8)
                            }
                        }
                        .padding()
                        .background(.gray.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.horizontal)
                                            
                        // review date
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Date")
                                .font(.headline)
                            Text("\(Date(), formatter: dateFormatter)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Divider().overlay(Color.white)
                        }
                        .padding(.horizontal)
                        
                        // rating section
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
                        
                        // review text section
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
                    .navigationBarTitle("\(album.title)", displayMode: .inline)
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
                        self.checkForListenList()
                        self.fetchExistingReview()
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text(""), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                    }

                }
                
            }
            
        }
    }
    
    private func fetchExistingReview() {
        guard let userID = session.currentUserID else {
            print("No current user ID found")
            return
        }
        
        FirebaseUserData().fetchUserReview(currentUserID: userID, albumID: album.firebaseKey) { fetchedUserReview, error in
            if let error = error {
                print("Failed to fetch user review: \(error.localizedDescription)")
            } else if let fetchedUserReview = fetchedUserReview {
                self.originalReviewText = fetchedUserReview.reviewText
                self.originalRating = fetchedUserReview.rating
                self.reviewID = fetchedUserReview.albumReviewID
                self.updateStarStates(rating: fetchedUserReview.rating)
                
                self.reviewText = self.originalReviewText
                self.rating = self.originalRating
            }
        }
    }
    
    private func saveReview() {
        guard let userID = session.currentUserID else {
            print("No current user ID found")
            return
        }
        
        if let validationError = validateReview() {
            alertMessage = validationError
            showAlert = true
            return
        }
        
        let albumReviewID = self.reviewID.isEmpty ? UUID().uuidString: self.reviewID
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let newRating = self.rating - self.originalRating
        
        let review = AlbumReview(
            albumReviewID: albumReviewID,
            userID: userID,
            albumKey: album.firebaseKey,
            rating: rating,
            reviewText: reviewText,
            reviewTimestamp: timestamp
        )
        
        if hasReviewChanged() {
            handleReviewChange(review: review, newRating: newRating)
        } else {
            evaluateListenList()
            self.showModal = false
        }
    }
    
    private func validateReview() -> String? {
        // user must submit a rating if they've written a review
        if !reviewText.isEmpty && rating <= 0 {
            return "Rating is required to submit the review"
        }
        
        // ensure review text does not exceed 1000 characters
        if reviewText.count > 1000 {
            return "Review must not exceed 1000 characters"
        }
        
        return nil
    }
    
    private func hasReviewChanged() -> Bool {
        return self.originalRating != self.rating || self.originalReviewText != self.reviewText
    }
    
    private func handleReviewChange(review: AlbumReview, newRating: Double) {
        if review.rating > 0 {
            postReview(review: review, ratingSumIncrement: newRating)
        } else {
            deleteReview()
        }
    }
    
    private func postReview(review: AlbumReview, ratingSumIncrement: Double) {
        guard let userID = session.currentUserID else {
            print("No current user ID found")
            return
        }
        
        // fetch the activity ID
        FirebaseUserData().checkActivityExists(userID: userID, albumReviewID: review.albumReviewID) { activityID in
            // post the album review
            FirebaseDataManager().postAlbumReview(albumID: album.firebaseKey, review: review, ratingSumIncrement: ratingSumIncrement, activityID: activityID) { error in
                if let error = error {
                    print("Error posting review: \(error.localizedDescription)")
                } else {
                    FirebaseUserData().removeFromListenList(currentUserID: userID, albumID: album.firebaseKey)
                    alertMessage = "Saved review!"
                    showAlert = true
                    self.showModal = false
                }
            }
        }
    }
    
    private func deleteReview() {
        FirebaseDataManager().deleteAlbumReview(userID: session.currentUserID ?? "", albumID: album.firebaseKey, reviewID: self.reviewID) { error in
            if let error = error {
                print("Error deleting review: \(error.localizedDescription)")
            } else {
                evaluateListenList()
                self.showModal = false
            }
        }
    }
    
    private func checkForListenList() {
        FirebaseUserData().isInListenList(uid: session.currentUserID ?? "", albumID: album.firebaseKey) { inListenList in
            if inListenList {
                self.listenList = true
            } else {
                self.listenList = false
            }
        }
    }
    
    private func evaluateListenList() {
        if self.listenList {
            FirebaseUserData().addToListenList(currentUserID: session.currentUserID ?? "", albumID: album.firebaseKey)
        } else {
            FirebaseUserData().removeFromListenList(currentUserID: session.currentUserID ?? "", albumID: album.firebaseKey)
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
        
        // fill stars up to the clicked index
        for i in 0..<index {
            starStates[i] = .full
        }
        // empty stars after the clicked index
        for i in (index + 1)..<starStates.count {
            starStates[i] = .empty
        }
        
        updateRating()
    }
    
    private func updateRating() {
        rating = starStates.reduce(0.0) { $0 + $1.rawValue }
    }
    
    private func updateStarStates(rating: Double) {
        let totalStars = 5  // Assuming you have 5 stars
        let roundedRating = Int(rating.rounded(.towardZero)) // Number of full stars
        let hasHalfStar = rating - Double(roundedRating) >= 0.5
        
        // reset all stars to empty
        starStates = Array(repeating: .empty, count: totalStars)
        
        // fill full stars
        for i in 0..<roundedRating {
            if i < totalStars {
                starStates[i] = .full
            }
        }
        
        // handle half star if needed
        if roundedRating < totalStars && hasHalfStar {
            starStates[roundedRating] = .half
        }
    }
    
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()


