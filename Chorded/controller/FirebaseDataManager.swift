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
    
    func addAlbum(album: Album, completion: @escaping (Error?) -> Void) {

        //adds album to Albums
        let albumRef = databaseRef.child("Albums").childByAutoId()
        let albumKey = albumRef.key ?? UUID().uuidString
        
        var albumWithKey = album
        albumWithKey.firebaseKey = albumKey
        let albumData = albumWithKey.toDictionary()
        var updates: [String: Any] = ["/Albums/\(albumKey)": albumData]
        
        //adds AlbumIndex node for querying for firebase key given album title and artist name
        for artistName in album.artistNames {
            databaseRef.child("AlbumIndex").child(album.title).child(artistName)
            updates["/AlbumIndex/\(album.title)/\(artistName)"] = albumKey
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
                        "images": "",
                        "albums": [albumKey]
                    ]
                    updates["/Artists/\(album.artistID[index])"] = newArtistData
                }
                dispatchGroup.leave()
            }
            
        }
        
        dispatchGroup.notify(queue: .main) {
            Database.database().reference().updateChildValues(updates) { error, _ in
                if let error = error {
                    print("Error updating database: \(error.localizedDescription)")
                } else {
                    print("Successfully updated database with new album and artist info")
                }
                completion(error)
            }
        }
    }
    
//    func fetchAlbum(firebaseKey: String, completion: @escaping (Album?, Error?) -> Void) {
//        let albumRef = databaseRef.child("Albums").child(firebaseKey)
//        
//    }
    
    // Artists
    
    func addArtist(artist: Artist, completion: @escaping (Error?) -> Void) {
//        let artistRef = databaseRef.child("Artists").child(String(artist.discogsID))
//        artistRef.setValue(artist.toDictionary()) { error, _ in
//            completion(error)
//        }
        
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
    
    func fetchArtist(completion: @escaping ([Artist]?, Error?) -> Void) {
        
    }
    
    //Users
    func addUser(user: User, completion: @escaping (Error?) -> Void) {
        
    }
    
    func fetchUser(completion: @escaping ([User]?, Error?) -> Void) {
        
    }
    
//    private func parseAlbum(from data: [String: AnyObject]) -> Album {
//        let discogsID = data[
//    }
    
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
            "genres": genres,
            "styles": styles,
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
            "image": image,
            "albums": albums
        ]
    }
}

extension User {
    
}
