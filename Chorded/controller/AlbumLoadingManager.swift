//
//  AlbumLoadingManager.swift
//  Chorded
//
//  Created by Janice Wong on 6/15/24.
//

import Foundation

class AlbumLoadingManager {
    //discogs allows 60 for authenticated requests
//    private let rateLimiter = RateLimiter(maxRequestsPerMinute: 60)
    private let rateLimiter = RateLimiter()
    
//    func loadAlbums(fileName: String) {
//
//    }
    
    func loadAlbumList(fileName: String, listName: String) {
        guard let filePath = Bundle.main.path(forResource: fileName, ofType: "txt", inDirectory: "albumInfo") else {
            print("Error: \(listName) file not found.")
            return
        }
        do {
            let fileContent = try String(contentsOfFile: filePath, encoding: .utf8)
            let lines = fileContent.components(separatedBy: .newlines)
            var albumList = [LoadedAlbum]()
            
            // skips first line (category labels)
            for (index, line) in lines.dropFirst().enumerated() {
                let components = line.split(separator: "\t")
                if components.count == 2 {
                    let title = String(components[0])
                    let artistString = String(components[1])
                    let artistList = String(components[1]).split(separator: ";").map { String($0) }
                    albumList.append(LoadedAlbum(title: title, artistList: artistList, artistString: artistString, index: index))
                }
            }
            // Process albums with Discogs and Firebase
            var albumKeys = [String]()
            processAlbumListSequentially(albumList, listName: listName, albumKeys: &albumKeys) {
                print("All albums processed for \(listName)")
            }
        } catch {
            print("Error reading file for \(listName) albums.")
        }
    }
    
    private func processAlbumListSequentially(_ albumList: [LoadedAlbum], listName: String, index: Int = 0, albumKeys: inout [String], completion: @escaping () -> Void) {
        //checks if current index is within the bounds of albumList, if not -> all albums are processed
        guard index < albumList.count else {
            // all albums processed, call addAlbumList function
            print("\(albumList.count) keys sent to \(listName) list")
            FirebaseDataManager().addAlbumList(albumKeys, listName: listName)
            completion()
            return
        }
        
        let album = albumList[index]
        var localAlbumKeys = albumKeys // create a local copy of albumKeys
        processAlbum(album, listName: listName) { firebaseAlbumKey in
            // append the Firebase key to the local array
            localAlbumKeys.append(firebaseAlbumKey)
            // process next album after the current one is completed
            self.processAlbumListSequentially(albumList, listName: listName, index: index + 1, albumKeys: &localAlbumKeys, completion: completion)
        }
        
        albumKeys = localAlbumKeys // update the original albumKeys array

    }
    
    private func processAlbum(_ album: LoadedAlbum, listName: String, completion: @escaping (String) -> Void) {
        FirebaseDataManager().doesAlbumExist(title: album.title, artists: album.artistList) { exists, firebaseAlbumKey, _ in
            if exists, let firebaseAlbumKey = firebaseAlbumKey {
                print("\(album.title) exists in Firebase so just appending to \(listName) list")
                completion(firebaseAlbumKey)
            } else {
                print("\(album.title) does not exist in Firebase so storing and adding to \(listName) list")
                // required slots is the max number of api calls we might make per search of an album
                // ex: search for album, search for master release, search for nonmaster release, search for artist
                //going to +1 to the required slots just to be careful
                self.rateLimiter.executeRequest(requiredSlots: 5) {
                    DiscogsAPIManager().searchAlbum(albumName: album.title, artistName: album.artistString) { result in
                        switch result {
                        case .success(let album):
                            FirebaseDataManager().addAlbum(album: album) { firebaseAlbum, error in
                                if let error = error {
                                    print("Error storing \(listName) album title \(album.title): \(error.localizedDescription)")
                                } else if let firebaseAlbum = firebaseAlbum {
                                    print("Successfully stored \(firebaseAlbum.title) with key: \(firebaseAlbum.firebaseKey)")
                                    completion(firebaseAlbum.firebaseKey)
                                }
                            }
                        case .failure (let error):
                            print("Error fetching \(album.title): \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
    
}


struct LoadedAlbum {
    let title: String
    let artistList: [String]
    let artistString: String
    let index: Int
}
