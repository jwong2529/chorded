//
//  SearchData.swift
//  Chorded
//
//  Created by Janice Wong on 7/31/24.
//

import Foundation
import Firebase

class SearchData {
    private var databaseRef: DatabaseReference = Database.database().reference()

    func searchAlbums(with query: String, completion: @escaping ([AlbumIndex]) -> Void) {
        let fixedQuery = FixStrings().normalizeString(query)
        guard !fixedQuery.isEmpty else {
            completion([])
            return
        }
        
        databaseRef.child("AlbumIndex").queryOrderedByKey().queryStarting(atValue: fixedQuery).queryEnding(atValue: fixedQuery + "\u{f8ff}").observeSingleEvent(of: .value) { snapshot in
            var newAlbums = [AlbumIndex]()
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let albumDict = snapshot.value as? [String: Any],
                   let artistNamesDict = albumDict["ArtistNames"] as? [String: String],
                   let coverImageURL = (albumDict["Images"] as? [String: String])?["coverImageURL"],
                   let albumName = albumDict["AlbumTitle"] as? String {
                    let artistNames = Array(artistNamesDict.keys)
                    //each artist in AlbumIndex has the same firebase key
                    let firebaseKey = artistNamesDict.first?.value ?? ""
                    let album = AlbumIndex(id: firebaseKey, title: albumName, artistNames: artistNames, coverImageURL: coverImageURL)
                    newAlbums.append(album)
                }
            }
            completion(newAlbums)
        }
    }
    
    func searchArtists(with query: String, completion: @escaping ([ArtistIndex]) -> Void) {
        let fixedQuery = FixStrings().normalizeString(query)
        guard !fixedQuery.isEmpty else {
            completion([])
            return
        }
        
        databaseRef.child("ArtistIndex").queryOrderedByKey().queryStarting(atValue: fixedQuery).queryEnding(atValue: fixedQuery + "\u{f8ff}").observeSingleEvent(of: .value) { snapshot in
            var newArtists = [ArtistIndex]()
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let artistDict = snapshot.value as? [String: Any],
                   let discogsID = artistDict["discogsID"] as? Int,
                   let artistName = artistDict["name"] as? String,
                   let profilePicture = artistDict["profilePicture"] as? String {
                    let artist = ArtistIndex(id: discogsID, name: artistName, profilePicture: profilePicture)
                    newArtists.append(artist)
                }
            }
            completion(newArtists)
        }
        
    }
}
