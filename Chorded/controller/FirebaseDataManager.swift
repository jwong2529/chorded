//
//  FirebaseDataManager.swift
//  Chorded
//
//  Created by Janice Wong on 6/2/24.
//

import Foundation
import Firebase
import FirebaseDatabase

class FirebaseDataManager {
    private let databaseRef: DatabaseReference
    
    init() {
        databaseRef = Database.database().reference()
    }
    
    // Albums
    
    func doesAlbumExist(title: String, artists: [String], completion: @escaping (Bool, String?, String?) -> Void) {
        let normalizedTitle = FixStrings().normalizeString(title)
        
        let albumIndexRef = databaseRef.child("AlbumIndex").child(normalizedTitle)
        
        albumIndexRef.observeSingleEvent(of: .value) { snapshot in
            guard let albumDict = snapshot.value as? [String: Any], 
                  let artistNamesDict = albumDict["ArtistNames"] as? [String: String],
                  let imagesDict = albumDict["Images"] as? [String: String],
                  let coverImageURL = imagesDict["coverImageURL"] else {
                completion(false, nil, nil)
                return
            }
            
            for storedArtist in artistNamesDict.keys {
                for artist in artists {
                    if FixStrings().normalizeString(artist) == storedArtist {
                        let firebaseKey = artistNamesDict[storedArtist]
                        completion(true, firebaseKey, coverImageURL)
                        return
                    }
                }
            }
            completion(false, nil, nil)
        } withCancel: { error in
            print("Error checking if album exists: \(error.localizedDescription)")
            completion(false, nil, nil)
        }
    }
    
    func addAlbum(album: Album, completion: @escaping (Album?, Error?) -> Void) {
        
        //adds album to Albums
        let albumRef = databaseRef.child("Albums").childByAutoId()
        let albumKey = albumRef.key ?? UUID().uuidString
        
        var albumWithKey = album
        albumWithKey.firebaseKey = albumKey
        let albumData = albumWithKey.toDictionary()
                
        var updates: [String: Any] = ["/Albums/\(albumKey)": albumData]
        
        let albumIndexKey = FixStrings().normalizeString(albumWithKey.title)
        
        //adds AlbumIndex node for querying for firebase key given album title and artist name
        var artistNamesDict: [String: String] = [:]
        for index in albumWithKey.artistNames.indices {
            let normalizedArtistName = FixStrings().normalizeString(albumWithKey.artistNames[index])
            artistNamesDict[normalizedArtistName] = albumKey
        }
        let albumDetails: [String: Any] = [
            "AlbumTitle": albumWithKey.title,
            "ArtistNames": artistNamesDict,
            "Images": ["coverImageURL": albumWithKey.coverImageURL]
        ]
        updates["/AlbumIndex/\(albumIndexKey)"] = albumDetails
        
        //update Artists node with the album ID
        
        let dispatchGroup = DispatchGroup()
        
        for index in albumWithKey.artistID.indices {
            dispatchGroup.enter()
            let artistRef = databaseRef.child("Artists").child(String(albumWithKey.artistID[index]))
            artistRef.observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists() {
                    // Artist with the given Discogs ID already exists so append album to album list
                    if var artistData = snapshot.value as? [String: Any] {
                        var currentAlbums = artistData["albums"] as? [String] ?? []
                        currentAlbums.append(albumKey)
                        artistData["albums"] = currentAlbums
                        updates["/Artists/\(albumWithKey.artistID[index])/albums"] = currentAlbums
                    }
                    dispatchGroup.leave()
                    
                } else {
                    DiscogsAPIManager().fetchArtistDetails(artistID: albumWithKey.artistID[index]) { result in
                        switch result {
                        case .success(let artist):
                            print("Discogs artist fetched successfully: \(artist.name)")
                            
                            let artistData: [String: Any] = [
                                "name": artist.name,
                                "profileDescription": artist.profileDescription,
                                "discogsID": artist.discogsID,
                                "imageURL": artist.imageURL,
                                "albums": [albumKey]
                            ]
                            
                            updates["Artists/\(albumWithKey.artistID[index])"] = artistData
                            
                            let cleanArtistName = FixStrings().normalizeString(albumWithKey.artistNames[index])
                            self.addArtistIndex(cleanedArtistName: cleanArtistName,artist: artist) { error in
                                if let error = error {
                                    print("Error adding artist index: \(error.localizedDescription)")
                                }
//                                dispatchGroup.leave()
                            }
                            
                        case .failure(let error):
                            print("Failed to fetch Discogs artist named \(albumWithKey.artistNames[index]) with ID as \(albumWithKey.artistID[index]): \(error.localizedDescription)")
                        }
                        dispatchGroup.leave()

                    }
                }
            }
            
        }
        
        dispatchGroup.notify(queue: .main) {
            print("Updating database with new album and artist info")
            Database.database().reference().updateChildValues(updates) { error, _ in
                if let error = error {
                    print("Error updating database: \(error.localizedDescription)")
                    completion(nil, error)
                } else {
                    print("Successfully updated database with new album and artist info")
                    completion(albumWithKey, nil)
                }
            }
        }
    }
    
    func fetchAlbum(firebaseKey: String, completion: @escaping (Album?, Error?) -> Void) {
        let albumRef = databaseRef.child("Albums").child(firebaseKey)
        
        albumRef.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists(), let albumData = snapshot.value as? [String: Any] else {
                completion(nil, NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Album not found in Firebase"]))
                return
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: albumData, options: [])
                let album = try JSONDecoder().decode(Album.self, from: jsonData)
                completion(album, nil)
            } catch {
                completion(nil, error)
            }
        }
        
    }
    
    // Artists
    
    //this function still needs testing
    func addArtist(artist: Artist, completion: @escaping (Error?) -> Void) {
        
        let artistRef = Database.database().reference().child("Artists")
        let query = artistRef.queryOrdered(byChild: "discogsID").queryEqual(toValue: artist.discogsID)
        
        query.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                // Artist with the given Discogs ID already exists
                completion(nil)
            } else {
                //Artist doesn't exist, add to Firebase
                artistRef.child(String(artist.discogsID))
                artistRef.setValue(artist.toDictionary()) { error, _ in
                    completion(error)
                }
            }
        }
    }
    
    func addArtistIndex(cleanedArtistName: String, artist: Artist, completion: @escaping (Error?) -> Void) {
        let artistIndexRef = databaseRef.child("ArtistIndex")
        let artistData: [String: Any] = [
            "name": artist.name,
            "discogsID": artist.discogsID,
            "profilePicture": artist.imageURL
        ]
        artistIndexRef.child(cleanedArtistName).setValue(artistData) { error, _ in
            completion(error)
        }
        
    }
    
    func fetchArtist(discogsKey: Int, completion: @escaping (Artist?, Error?) -> Void) {
        let artistRef = databaseRef.child("Artists").child(String(discogsKey))
        
        artistRef.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists(), let artistData = snapshot.value as? [String: Any] else {
                completion(nil, NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Artist not found in Firebase"]))
                return
            }

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: artistData, options: [])
                let artist = try JSONDecoder().decode(Artist.self, from: jsonData)
                completion(artist, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
    
    // Lists
    
    func addTrendingList(_ albumKeys: [String]) {
        
        //preserves the order the albums are listed in the original txt file
        var indexedAlbums: [String: Any] = [:]
        for (index, key) in albumKeys.enumerated() {
            indexedAlbums["\(index)"] = key
        }

        let trendingAlbumsRef = databaseRef.child("CustomAlbumLists").child("TrendingAlbums")
        trendingAlbumsRef.setValue(indexedAlbums) { error, _ in
            if let error = error {
                print("Error storing trending album keys: \(error.localizedDescription)")
            } else {
                print("Trending album keys stored successfully.")
            }
        }
    }
    
    func fetchTrendingList(completion: @escaping ([String]?, Error?) -> Void) {
        let trendingRef = databaseRef.child("CustomAlbumLists").child("TrendingAlbums")

        trendingRef.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists(), let trendingAlbumsData = snapshot.value as? [String] else {
                completion(nil, NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Trending albums not found in Firebase"]))
                return
            }
            completion(trendingAlbumsData, nil)
        }
    }
    
    func addAlbumList(_ albumKeys: [String], listName: String) {
        
        //preserves the order the albums are listed in the original txt file
        var indexedAlbums: [String: Any] = [:]
        for (index, key) in albumKeys.enumerated() {
            indexedAlbums["\(index)"] = key
        }
        
        let listRef = databaseRef.child("CustomAlbumLists").child(listName)
        listRef.setValue(indexedAlbums) { error, _ in
            if let error = error {
                print("Error adding \(listName) list: \(error.localizedDescription)")
            } else {
                print("Successfully added \(listName) list")
            }
        }
    }
    
    func fetchAlbumList(listName: String, completion: @escaping ([String]?, Error?) -> Void) {
        let listRef = databaseRef.child("CustomAlbumLists").child(listName)
        
        listRef.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists(), let albumsData = snapshot.value as? [String] else {
                completion(nil, NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "\(listName) list not found in Firebase"]))
                return
            }
            completion(albumsData, nil)
        }
    }
    
    func fetchAlbumListAndDetails(listName: String, completion: @escaping ([Album]?, Error?) -> Void) {
        var fetchedAlbums: [Album] = []
        let dispatchGroup = DispatchGroup()
        
        fetchAlbumList(listName: listName) { albumKeys, error in
            if let error = error {
                completion(nil, error)
            } else if let albumKeys = albumKeys {
                for albumKey in albumKeys {
                    dispatchGroup.enter()
                    self.fetchAlbum(firebaseKey: albumKey) { album, error in
                        if let error = error {
                            print("Failed to fetch album: \(error.localizedDescription)")
                        } else if let album = album {
                            fetchedAlbums.append(album)
                        }
                        dispatchGroup.leave()
                    }
                }
                dispatchGroup.notify(queue: .main) {
                    completion(fetchedAlbums, nil)
                }
            }
        }
    }
    
    func postAlbumReview(albumID: String, review: AlbumReview, completion: @escaping (Error?) -> Void) {
        let reviewData: [String: Any] = [
            "id": review.id,
            "userID": review.userID,
            "albumKey": review.albumKey,
            "rating": review.rating,
            "reviewText": review.reviewText,
            "timestamp": review.timestamp
        ]
        
        //Add review to corresponding AlbumReviews list (key: albumkey, value: list of AlbumReviews)
        let albumReviewsRef = databaseRef.child("AlbumReviews").child(albumID).child("Reviews").child(review.id)
        let totalRatingSumRef = databaseRef.child("AlbumReviews").child(albumID).child("TotalRatingSum")
        let userReviewsRef = databaseRef.child("UserReviews").child(review.userID).child(review.id)
        
        albumReviewsRef.setValue(reviewData) { error, _ in
            if let error = error {
                completion(error)
                return
            }
            
            // add review to UserReviews list
            userReviewsRef.setValue(reviewData) { error, _ in
                if let error = error {
                    completion(error)
                    return
                }
                
                //update TotalRatingSum
                totalRatingSumRef.runTransactionBlock { currentData -> TransactionResult in
                    if var totalRatingSum = currentData.value as? Double {
                        totalRatingSum += review.rating
                        currentData.value = totalRatingSum
                    } else {
                        currentData.value = review.rating
                    }
                    return TransactionResult.success(withValue: currentData)
                }
                completion(nil)
            }
        }
    }
    
    func fetchAlbumReviews(albumID: String, completion: @escaping ([AlbumReview]?, Error?) -> Void) {
        let albumReviewsRef = databaseRef.child("AlbumReviews").child(albumID).child("Reviews")
        
        albumReviewsRef.queryOrdered(byChild: "timestamp").observeSingleEvent(of: .value) { snapshot in
            var albumReviews: [AlbumReview] = []
            
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let reviewData = snapshot.value as? [String: Any],
                   let id = reviewData["id"] as? String,
                   let userID = reviewData["userID"] as? String,
                   let albumKey = reviewData["albumKey"] as? String,
                   let rating = reviewData["rating"] as? Double,
                   let reviewText = reviewData["reviewText"] as? String,
                   let timestamp = reviewData["timestamp"] as? String {
                    let review = AlbumReview(id: id, userID: userID, albumKey: albumKey, rating: rating, reviewText: reviewText, timestamp: timestamp)
                    albumReviews.append(review)
                }
            }
            
            completion(albumReviews, nil)
        }
    }
    
}

extension Album {
    init?(snapshot: DataSnapshot) {
        guard let value = snapshot.value as? [String: Any] else {
            return nil
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: value)
            let album = try JSONDecoder().decode(Album.self, from: jsonData)
            self = album
        } catch {
            return nil
        }
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "firebaseKey": firebaseKey,
            "title": title,
            "artistID": artistID,
            "artistNames": artistNames,
            "genres": genres ?? [],
            "styles": styles ?? [],
            "year": year,
            "albumTracks": albumTracks,
            "coverImageURL": coverImageURL,
            "albumRating": albumRating ?? NSNull()
        ]
    }
}

extension Artist {
    init?(snapshot: DataSnapshot) {
        guard let value = snapshot.value as? [String: Any] else {
            return nil
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: value)
            let artist = try JSONDecoder().decode(Artist.self, from: jsonData)
            self = artist
        } catch {
            return nil
        }
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "name": name,
            "profileDescription": profileDescription,
            "discogsID": discogsID,
            "imageURL": imageURL,
            "albums": albums
        ]
    }
}

struct AlbumIndex: Identifiable {
    var id: String
    var title: String
    var artistNames: [String]
    var coverImageURL: String
}

struct ArtistIndex: Identifiable {
    var id: Int
    var name: String
    var profilePicture: String
}


