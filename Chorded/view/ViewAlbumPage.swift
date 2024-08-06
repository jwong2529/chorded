//
//  ViewAlbumPage.swift
//  Chorded
//
//  Created by Janice Wong on 6/6/24.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct ViewAlbumPage: View {
//    @State private var album: Album
    let albumKey: String

    @State private var showTracklist = false
    @State private var ratingProgress: CGFloat = 0.0
    @State var selection1: String? = "Tracklist"
    @State private var album = Album(title: "", artistID: [0], artistNames: [""], genres: [""], styles: [""], year: 0, albumTracks: [""], coverImageURL: "")
    @State private var artists = [Artist]()
    @State private var unfilteredReviews: [AlbumReview] = [] //used to consider ratings from reviews without any reviewText
    @State private var reviews: [AlbumReview] = []
    
    @State private var showReviewModal = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                ScrollView {
                    VStack(spacing: 20) {
                        if album.coverImageURL != "", let url = URL(string: album.coverImageURL) {
                            WebImage(url: url)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 200, height: 200)
                                .clipped()
                                .cornerRadius(10)
                                .shadow(color: .blue, radius: 5)
                                .padding(.top, 20)
                        } else {
                            PlaceholderAlbumCover(width: 200, height: 200)
                                .padding(.top, 20)
                        }
                        
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(album.title)
                                    .font(.system(size: 27, weight: .bold, design: .default))
                                    .foregroundColor(.white)
                                HStack(spacing: 10) {
//                                    Text(album.artistNames.joined(separator: ", "))
//                                        .foregroundColor(.white)
                                    ClickableArtistsView(artists: artists)
                                    Circle()
                                        .fill(Color.gray)
                                        .frame(width: 5, height: 5)
                                    Text(String(album.year))
                                        .foregroundColor(.gray)
                                }
                            }
                            Spacer()
                            if unfilteredReviews.count > 0 {
                                ZStack {
                                    RatingRing(rating: $ratingProgress)
                                        .frame(width: 50, height: 50)
                                }
                                .padding(.leading)
                            }
                                
                        }
                        .padding(.horizontal)
                        
                        DropdownList(
                            selection: $selection1,
                            options: album.albumTracks
                        )
                        .padding(.horizontal)
                        
                        HStack {
                            Text("Rate, review, add to listen list")
                            Spacer()
                            Image(systemName: "ellipsis")
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .contentShape(Rectangle())
                        .background(.gray.opacity(0.4))
                        .cornerRadius(20)
                        .padding(.horizontal)
                        .onTapGesture {
                            self.showReviewModal = true
                        }
                        
                        
                        // later, group the listened by and wants to listen parts and put in another class and only display if users have friends that have this album in their list
                        NavigationLink(destination: ViewReviewPage(reviews: reviews)) {
                            HStack {
                                Text("LISTENED BY")
//                                    .font(.system(size: 20, weight: .medium, design: .default))
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.blue)
                            }
                            .contentShape(Rectangle())
                            .padding(.horizontal)
                        }
                        .buttonStyle(HighlightButtonStyle())
                        HStack(alignment: .top) {
                            HStack(spacing: 15) {
                                ForEach(0..<4) { _ in
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .foregroundColor(.gray)
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                        .padding(.trailing, 10)
                                }
                            }
                            .padding(.horizontal)
                            Spacer()
                        }
                        
                        NavigationLink(destination: ViewReviewPage(reviews: reviews)) {
                            HStack {
                                Text("WANTS TO LISTEN")
//                                    .font(.system(size: 20, weight: .medium, design: .default))
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.blue)
                            }
                            .contentShape(Rectangle())
                            .padding(.horizontal)
                        }
                        .buttonStyle(HighlightButtonStyle())
                        HStack(alignment: .top) {
                            HStack(spacing: 15) {
                                ForEach(0..<4) { _ in
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .foregroundColor(.gray)
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                        .padding(.trailing, 10)
                                }
                            }
                            .padding(.horizontal)
                            Spacer()
                        }

                        NavigationLink(destination: ViewReviewPage(reviews: reviews)) {
                            HStack {
                                Text("Reviews - \(reviews.count)")
//                                    .font(.system(size: 20, weight: .medium, design: .default))
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.blue)
                            }
                            .contentShape(Rectangle())
                            .padding()
                            .background(.purple.opacity(0.7))
                            .cornerRadius(25)
                        }
                        .buttonStyle(HighlightButtonStyle())
                        .padding(.horizontal)
                        
                        ViewAlbumPageMiniBar(artists: artists, album: album)
                        
                    }
                }
            }
        }
        .onAppear {
            fetchData()
        }
        .navigationBarItems(trailing: Button(action: {
            self.showReviewModal = true
        }) {
            Image(systemName: "ellipsis")
                .imageScale(.large)
                .padding()
        })
        .navigationTitle(album.title)
        .sheet(isPresented: $showReviewModal) {
            PostReviewModal(showModal: self.$showReviewModal, album: self.album)
        }
        .refreshable {
            fetchData()
        }
    }
    
    
    private func fetchData() {
        fetchAlbum(firebaseKey: albumKey)
        fetchReviews(firebaseKey: albumKey)
        calculateAverageRating(firebaseKey: albumKey)
    }
    
    func fetchArtists(discogsKeys: [Int]) {
        let dispatchGroup = DispatchGroup()
        var fetchedArtists: [Artist] = []
        var fetchError: Error?
        
        for discogsKey in discogsKeys {
            dispatchGroup.enter()
            FirebaseDataManager().fetchArtist(discogsKey: discogsKey) { artist, error in
                defer {
                    dispatchGroup.leave()
                }
                if let artist = artist {
                    fetchedArtists.append(artist)
                } else if let error = error {
                    fetchError = error
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            if fetchError != nil {
                print("Couldn't fetch artists to display on album page")
            } else {
                self.artists = fetchedArtists
            }
        }
    }
    
    func fetchAlbum(firebaseKey: String) {
        FirebaseDataManager().fetchAlbum(firebaseKey: firebaseKey) { fetchedAlbum, error in
            if let error = error {
                print("Error fetching album:", error)
            } else if let fetchedAlbum = fetchedAlbum {
                self.album = fetchedAlbum
                fetchArtists(discogsKeys: fetchedAlbum.artistID)
            }
        }
    }
    
    private func fetchReviews(firebaseKey: String) {
        FirebaseDataManager().fetchAlbumReviews(albumID: firebaseKey) { reviews, error in
            if let error = error {
                print("Failed to fetch reviews for \(album.title): \(error)")
            } else {
                self.unfilteredReviews = reviews ?? []
                // filters out the reviews that only have a rating
                self.reviews = (reviews ?? []).filter { !$0.reviewText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty}
            }
        }
    }
    
    private func calculateAverageRating(firebaseKey: String) {
        let albumReviewsRef = Database.database().reference().child("AlbumReviews").child(firebaseKey)
        albumReviewsRef.observeSingleEvent(of: .value) { snapshot in
            guard let albumData = snapshot.value as? [String: Any],
                  let totalRatingSum = albumData["TotalRatingSum"] as? Double else {
                print("No total rating sum to fetch")
                return
            }
            
            let numOfReviews = Double(unfilteredReviews.count)
            let averageRating = (totalRatingSum / numOfReviews).rounded(toPlaces: 1)
            self.ratingProgress = averageRating
        }
    }
}

extension Double {
    // rounds the double to 'places' decimal places
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

#Preview {
    ViewAlbumPage(albumKey: "O0beOq2J7OO7IYxLXQY")
}


