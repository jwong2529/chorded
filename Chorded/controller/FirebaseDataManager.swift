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
    
    func doesAlbumExist(title: String, artists: [String], completion: @escaping (Bool, String?) -> Void) {
        let normalizedTitle = FixStrings().normalizeString(title)
        
        let albumIndexRef = databaseRef.child("AlbumIndex").child(normalizedTitle)
        
        albumIndexRef.observeSingleEvent(of: .value) { snapshot in
            guard let albumDict = snapshot.value as? [String: String] else {
                completion(false, nil)
                return
            }
            
            for storedArtist in albumDict.keys {
                for artist in artists {
                    if FixStrings().normalizeString(artist) == storedArtist {
                        let firebaseKey = albumDict[storedArtist]
                        completion(true, firebaseKey)
                        return
                    }
                }
            }
            completion(false, nil)
        } withCancel: { error in
            print("Error checking if album exists: \(error.localizedDescription)")
            completion(false, nil)
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
        
        
        let albumIndexKey = FixStrings().normalizeString(album.title)
        
        //adds AlbumIndex node for querying for firebase key given album title and artist name
        for artistName in album.artistNames {
//            databaseRef.child("AlbumIndex").child(album.title).child(artistName)
            let normalizedArtistName = FixStrings().normalizeString(artistName)
            updates["/AlbumIndex/\(albumIndexKey)/\(normalizedArtistName)"] = albumKey
        }
   
        //update Artists node with the album ID
        
        let dispatchGroup = DispatchGroup()
        
        for index in album.artistID.indices {
            dispatchGroup.enter()
            
            let artistRef = Database.database().reference().child("Artists").child(String(album.artistID[index]))
            artistRef.observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists() {
                    // Artist with the given Discogs ID already exists so append album to album list
                    if var artistData = snapshot.value as? [String: Any] {
                        var currentAlbums = artistData["albums"] as? [String] ?? []
                        currentAlbums.append(albumKey)
                        artistData["albums"] = currentAlbums
                        updates["/Artists/\(album.artistID[index])"] = artistData
                    }
                    
                } else {
                    //Artist doesn't exist, add to Firebase
                    let newArtistData: [String: Any] = [
                        "name": album.artistNames[index],
                        "discogsID": album.artistID[index],
                        "imageURL": "",
                        "albums": [albumKey]
                    ]
                    updates["/Artists/\(album.artistID[index])"] = newArtistData
                }
                dispatchGroup.leave()
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
    
    // Users
    func addUser(user: User, completion: @escaping (Error?) -> Void) {
        
    }
    
    func fetchUser(completion: @escaping ([User]?, Error?) -> Void) {
        
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
            "coverImageURL": coverImageURL
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
            "discogsID": discogsID,
            "imageURL": imageURL,
            "albums": albums
        ]
    }
}

extension User {
    
}


