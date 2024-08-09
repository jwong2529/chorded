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

    @EnvironmentObject var session: SessionStore
    @State private var showTracklist = false
    @State private var ratingProgress: CGFloat = 0.0
    @State var selection1: String? = "Tracklist"
    @State private var album = Album(title: "", artistID: [0], artistNames: [""], genres: [""], styles: [""], year: 0, albumTracks: [""], coverImageURL: "")
    @State private var artists = [Artist]()
    @State private var unfilteredReviews: [AlbumReview] = [] //used to consider ratings from reviews without any reviewText
    @State private var reviews: [AlbumReview] = []
    @State private var listenedByUsers: [User] = []
    @State private var wantsToListenUsers: [User] = []
    
    @State private var showReviewModal = false
    
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                ScrollView {
                    if !isLoading {
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Spacer()
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
                                Spacer()
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
                            
                            Divider().overlay(Color.white).padding(.horizontal)
                            
                            DropdownList(
                                selection: $selection1,
                                options: album.albumTracks
                            )
                            .padding(.horizontal)
                            
                            Divider().overlay(Color.white).padding(.horizontal)
                            
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
                            
                            Divider().overlay(Color.white).padding(.horizontal)
                            
                            if !listenedByUsers.isEmpty {
                                AlbumPageOtherUsersView(users: listenedByUsers, text: "LISTENED BY")
                                Divider().overlay(Color.white).padding(.horizontal)
                            }
                            if !wantsToListenUsers.isEmpty {
                                AlbumPageOtherUsersView(users: wantsToListenUsers, text: "WANTS TO LISTEN")
                                Divider().overlay(Color.white).padding(.horizontal)
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
                            
                            Divider().overlay(Color.white).padding(.horizontal)

                            ViewAlbumPageMiniBar(artists: artists, album: album)
                            
                        }
                    } else {
                        ProgressView("Loading...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
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
        fetchIfInFriendsList()
        self.isLoading = false
    }
    
    private func fetchArtists(discogsKeys: [Int]) {
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
    
    private func fetchAlbum(firebaseKey: String) {
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
    
    private func fetchIfInFriendsList() {
        guard let currentUserID = session.currentUserID else { return }

        fetchUsersWhoReviewedAlbum(currentUserID: currentUserID, albumID: albumKey) { usersWhoReviewedAlbumList in
            self.listenedByUsers = usersWhoReviewedAlbumList
        }
        fetchUsersWithAlbumInListenList(currentUserID: currentUserID, albumID: albumKey) { usersWithAlbumInListenList in
            self.wantsToListenUsers = usersWithAlbumInListenList
        }
    }
    
    private func calculateAverageRating(firebaseKey: String) {
        let albumReviewsRef = Database.database().reference().child("AlbumReviews").child(firebaseKey)
        albumReviewsRef.observeSingleEvent(of: .value) { snapshot in
            guard let albumData = snapshot.value as? [String: Any],
                  let totalRatingSum = albumData["TotalRatingSum"] as? Double else {
                return
            }
            
            let numOfReviews = Double(unfilteredReviews.count)
            let averageRating = (totalRatingSum / numOfReviews).rounded(toPlaces: 1)
            self.ratingProgress = averageRating
        }
    }
    
    private func fetchUsersWithAlbumInListenList(currentUserID: String, albumID: String, completion: @escaping ([User]) -> Void) {
        FirebaseUserDataManager().fetchFollowing(uid: currentUserID) { followingList in
            var usersWithAlbumIDs: [String] = []
            let dispatchGroup = DispatchGroup()
            
            for userID in followingList {
                dispatchGroup.enter()
                FirebaseUserDataManager().isInListenList(uid: userID, albumID: albumID) { inListenList in
                    if inListenList {
                        usersWithAlbumIDs.append(userID)
                    }
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                // Fetch user details for the filtered IDs
                var usersWithAlbum: [User] = []
                let fetchGroup = DispatchGroup()
                
                for userID in usersWithAlbumIDs {
                    fetchGroup.enter()
                    FirebaseUserDataManager().fetchUserData(uid: userID) { user, error in
                        if let error = error {
                            print("Failed to fetch user \(userID): \(error.localizedDescription)")
                        } else if let user = user {
                            usersWithAlbum.append(user)
                        }
                        fetchGroup.leave()
                    }
                }
                
                fetchGroup.notify(queue: .main) {
                    completion(usersWithAlbum)
                }
            }
        }
    }

    private func fetchUsersWhoReviewedAlbum(currentUserID: String, albumID: String, completion: @escaping ([User]) -> Void) {
        FirebaseUserDataManager().fetchFollowing(uid: currentUserID) { followingList in
            var usersWhoReviewedIDs: [String] = []
            let dispatchGroup = DispatchGroup()
            
            for userID in followingList {
                dispatchGroup.enter()
                FirebaseUserDataManager().hasReviewedAlbum(uid: userID, albumID: albumID) { hasReviewed in
                    if hasReviewed {
                        usersWhoReviewedIDs.append(userID)
                    }
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                // Fetch user details for the filtered IDs
                var usersWhoReviewed: [User] = []
                let fetchGroup = DispatchGroup()
                
                for userID in usersWhoReviewedIDs {
                    fetchGroup.enter()
                    FirebaseUserDataManager().fetchUserData(uid: userID) { user, error in
                        if let error = error {
                            print("Failed to fetch user \(userID): \(error.localizedDescription)")
                        } else if let user = user {
                            usersWhoReviewed.append(user)
                        }
                        fetchGroup.leave()
                    }
                }
                
                fetchGroup.notify(queue: .main) {
                    completion(usersWhoReviewed)
                }
            }
        }
    }


}

struct AlbumPageOtherUsersView: View {
    var users: [User]
    var text: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(text)")
                .font(.subheadline)
                .foregroundColor(.white)
            
            HStack(spacing: 15) {
                ForEach(users.prefix(5), id: \.userID) { user in
                    NavigationLink(destination: ViewProfilePage(userID: user.userID)) {
                        if let url = URL(string: user.userProfilePictureURL) {
                            WebImage(url: url)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                        } else {
                            PlaceholderUserImage(width: 50, height: 50)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
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


