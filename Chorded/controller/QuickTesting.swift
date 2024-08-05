//
//  QuickTesting.swift
//  Chorded
//
//  Created by Janice Wong on 6/4/24.
//


import Foundation
import Combine

class QuickTesting: ObservableObject {
    @Published var albums: [Album] = []
    private var trendingAlbums = [Album]()
    
    init() {
        
//        DiscogsAPIManager().testingAPI()
        
//        FirebaseDataManager().fetchArtist(discogsKey: 82730) { artist, error in
//            if let error = error {
//                print("Failed to fetch artist: \(error.localizedDescription)")
//            } else if let artist = artist {
//                print("Fetched artist: \(artist)")
//            }
//        }
        
//        FirebaseUserData().fetchUserConnections(uid: "vRvcmGHequhSAj4buOKQztBeRTs1") { followingList, followersList in
//            print("Following list: \(followingList)")
//            print("Followers list: \(followersList)")
//        }
//        FirebaseUserData().fetchUserConnections(uid: "vRvcmGHequhSAj4buOKQztBeRTs1")
        
//        FirebaseUserData().fetchFollowing(uid: "vRvcmGHequhSAj4buOKQztBeRTs1") { followingList in
//            print("following list: \(followingList)")
//        }
//        
//        FirebaseUserData().fetchFollowers(uid: "vRvcmGHequhSAj4buOKQztBeRTs1") { followersList in
//            print("followers list: \(followersList)")
//        }
        
//        FirebaseUserData().checkUserConnections(uid: "vRvcmGHequhSAj4buOKQztBeRTs1")
        
//        AlbumLoadingManager().loadAlbumList(fileName: "trendingAlbums", listName: "TrendingAlbums")
//        AlbumLoadingManager().loadAlbumList(fileName: "greatestAlbumsRS", listName: "GreatestAlbumsOfAllTimeRS")
//        AlbumLoadingManager().loadAlbumList(fileName: "topLast25Yrs", listName: "TopAlbumsLast25Yrs")
        
//        FirebaseDataManager().fetchTrendingList { albumKeys, error in
//            if let error = error {
//                print("Failed to fetch trending album keys: \(error.localizedDescription)")
//            } else if let albumKeys = albumKeys {
//                print("Fetched trending album keys: \(albumKeys)")
//                // Do something with the fetched album keys
//            }
//        }
        
//        FirebaseDataManager().fetchAlbum(firebaseKey: "-NzgJWM2gxpU-fQliYjR") { album, error in
//            if let error = error {
//                print("Failed to fetch album: \(error.localizedDescription)")
//            } else if let album = album {
//                print("FETCHED ALBUM: \(album.title)")
//            }
//        }
        
//        FirebaseDataManager().fetchAlbumReviews(albumID: "-O0beOq2J7OO7IYxLXQY") { albumReview, error in
//            if let error = error {
//                print("failed to fetch album reviews: \(error)")
//            } else if let albumReview = albumReview {
//                print("Fetched album review: \(albumReview)")
//            }
//        }
        
        
//        DiscogsAPIManager().fetchArtistDetails(artistID: 5590213) { result in
//            switch result {
//            case .success(let artist):
//                print("DISCOGS ARTIST FETCHED SUCCESSFULLY: \(artist.imageURL)")
//            case .failure(let error):
//                print("FAILED TO FETCH DISCOGS ARTIST: \(error.localizedDescription)")
//            }
//        }
        
//        fetchTrendingAlbums()
        
//        let testTitle = "American Heartbreak"
//        let testArtists = ["Zach Bryan"]
//        FirebaseDataManager().doesAlbumExist(title: testTitle, artists: testArtists) { exists, firebaseKey, coverImageURL in
//            if exists {
//                print("\(testTitle) exists with key: \(firebaseKey ?? "No key)")")
//            } else {
//                print("Album does not exist")
//            }
//        }
        
//        let testString = "Travis Scott (2)"
//        print(FixStrings().deleteDistinctArtistNum(testString))
        
        
        
    }
    
    
}
