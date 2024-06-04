//
//  NetworkManager.swift
//  MusicReviewApp
//
//  Created by Janice Wong on 5/26/24.
//

import Foundation

class DiscogsAPIManager {
    static let shared = DiscogsAPIManager()
    
    private let baseURL = "https://api.discogs.com/"
    private let apiKey = DiscogsCreds.shared.discogsAPIKey
    private let apiSecret = DiscogsCreds.shared.discogsAPISecret
    private let apiCredsString = "key=\(DiscogsCreds.shared.discogsAPIKey)&secret=\(DiscogsCreds.shared.discogsAPISecret)"
        
    private func searchAlbum(albumName: String, artistName: String, completion: @escaping (Result<Album, Error>) -> Void) {
//        let searchURL = URL(string:"\(baseURL)database/search?q=\(albumName) \(artistName)&type=master&format=album&\(apiCredsString)")!
//        let searchURL = URL(string:"\(baseURL)database/search?q=\(albumName) \(artistName)&\(apiCredsString)")!
        let query = "release_title=\(albumName)&q=\(artistName)"
//        let query = "q=\(albumName) \(artistName)"
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error encoding URL components"])))
            return
        }
        
//        let searchURLString = "\(baseURL)database/search?\(encodedQuery)&per_page=1&page=1&\(apiCredsString)"
//        let searchURL = URL(string: "\(baseURL)database/search?\(encodedQuery)&per_page=1&page=1&\(apiCredsString)")!
//        guard let searchURL = URL(string: searchURLString) else {
//            print("Invalid search URL")
//            exit(1)
//        }
        
        let searchURL = URL(string: "\(baseURL)database/search?\(encodedQuery)&per_page=1&page=1&\(apiCredsString)")!
        
        var request = URLRequest(url: searchURL)
        request.setValue("Chorded/1.0", forHTTPHeaderField: "User-Agent")
        
        let task = URLSession.shared.dataTask(with: searchURL) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            do {
                let searchResponse = try JSONDecoder().decode(DiscogsSearchResponse.self, from: data)
                if let discogsAlbum = searchResponse.results.first {
                    
//                    print("id: \(discogsAlbum.master_id) title: \(discogsAlbum.title)")

                    self.fetchAlbumDetails(discogsAlbum: discogsAlbum, completion: completion)
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No album found"])))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    private func fetchAlbumDetails(discogsAlbum: DiscogsAlbum, completion: @escaping (Result<Album, Error>) -> Void) {
        
        //set the id num to master id unless it's equal to 0
//        let id_num = discogsAlbum.master_id != 0 ? discogsAlbum.master_id : discogsAlbum.id
//        var urlString = "\(baseURL)masters/\(discogsAlbum.master_id)?\(apiCredsString)"
//        
//        guard discogsAlbum.master_id != 0 else {
//            urlString = "\(baseURL)releases/\(discogsAlbum.id)?\(apiCredsString)"
//            return
//        }
        
        let urlString: String
        
        if discogsAlbum.master_id != 0 {
            urlString = "\(baseURL)masters/\(discogsAlbum.master_id)?\(apiCredsString)"
        } else {
            urlString = "\(baseURL)releases/\(discogsAlbum.id)?\(apiCredsString)"
        }
        
        guard let albumURL = URL(string: urlString) else {
            print("Invalid URL")
            exit(1)
        }
        
        var request = URLRequest(url: albumURL)
        request.setValue("Chorded/1.0", forHTTPHeaderField: "User-Agent")
        
        let task = URLSession.shared.dataTask(with: albumURL) { data, response, error in
            if let error = error {
                completion(.failure(error))
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            do {
                let albumDetails = try JSONDecoder().decode(DiscogsReleaseDetails.self, from: data)
//                let artistList = albumDetails.artists.map { Artist(name: $0.name, id: $0.id) }
                let album = Album(
                    title: albumDetails.title,
                    artistID: albumDetails.artists.map {$0.id},
                    artistNames: albumDetails.artists.map {$0.name},
                    genres: albumDetails.genres ?? [],
                    styles: albumDetails.styles ?? [],
                    year: albumDetails.year,
                    albumTracks: albumDetails.tracklist.map { $0.title},
                    coverImageURL: albumDetails.images.first?.uri ?? ""
                )
                completion(.success(album))
//                print(albumDetails)
//                print(album)
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    private func storeAlbum(_ album: Album) {
        //Check if album is already in the database
        //Firebase logic
//        let dataManager = FirebaseDataManager()
//        dataManager.addAlbum(album: album) { error in
//            if let error = error{
//                print("Error adding album to Firebase")
//            } else {
//                print("Album added successfully to Firebase")
//            }
//        }
        
        //Store cover image in Backblaze too
//        if let coverImageURL = album.coverImageURL {
//            storeCoverImage(url: coverImageURL)
//        }
    }
    
    private func storeCoverImage(url: URL) {
        //Use URLSession to download image data and upload to Backblaze
    }
    
    //return the trending albums as an array?
    func loadTrendingAlbums() {
        guard let filePath = Bundle.main.path(forResource: "trendingAlbums", ofType: "txt", inDirectory: "albumInfo") else {
            print("Error: Trending albums file not found.")
            return
        }
        do {
            let fileContent = try String(contentsOfFile: filePath, encoding: .utf8)
            let lines = fileContent.components(separatedBy: .newlines)
            var trendingAlbums = [TrendingAlbum]()
            
            //skips first line (category labels))
            for line in lines.dropFirst() {
                let components = line.split(separator: "\t")
                if components.count == 2 {
                    let title = String(components[0])
                    let artist = String(components[1])
                    trendingAlbums.append(TrendingAlbum(title: title, artist: artist))
                }
            }
            
            //process these albums with discogs and firebase
            var trendingAlbumKeys = [String]()
            let dispatchGroup = DispatchGroup()
            
            for trendingAlbum in trendingAlbums {
                dispatchGroup.enter()
                searchAlbum(albumName: trendingAlbum.title, artistName: trendingAlbum.artist) { result in
                    switch result {
                    case .success(let album):
//                        self.trendingAlbumsList.append(album)
                        FirebaseDataManager().addAlbum(album: album) { firebaseAlbum, error in
                            if let error = error {
                                print("Error storing trending album: \(error.localizedDescription)")
                            } else if let firebaseAlbum = firebaseAlbum {
                                print("Successfully stored album with key: \(firebaseAlbum.firebaseKey)")
                                trendingAlbumKeys.append(firebaseAlbum.firebaseKey)
                            }
                            dispatchGroup.leave()
                        }
                    case.failure(let error):
                        print("Error fetching album: \(error.localizedDescription)")
                        dispatchGroup.leave()
                    }
                }
            }
            
//            FirebaseDataManager().addTrendingList(trendingAlbumKeys)
            dispatchGroup.notify(queue: .main) {
                print("All albums processed. Trending album keys: \(trendingAlbumKeys)")
                FirebaseDataManager().addTrendingList(trendingAlbumKeys)
            }
            
        } catch {
            print("Error reading file for trending albums.")
        }
    }
    
    
    private func cleanString(_ input: String) -> String {
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet.whitespaces)
        return input.unicodeScalars.filter { allowedCharacters.contains($0) }.map { String($0) }.joined()
    }
    
    func testingAPI() {
//        let urlString = "https://api.discogs.com/database/search?release_title=fleetwood mac&q=fleetwood mac&per_page=1&page=1&\(apiCredsString)"
        let urlString = "https://api.discogs.com/masters/2890219?\(apiCredsString)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            exit(1)
        }

        var request = URLRequest(url: url)
        request.setValue("Chorded/1.0", forHTTPHeaderField: "User-Agent")

        // Create a data task to fetch the data
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // Check for errors
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            // Check for response status code
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response")
                return
            }
            
            // Check if data is available
            guard let data = data else {
                print("No data received")
                return
            }
            
            // Decode the JSON data
            do {
                let decoder = JSONDecoder()
                // Define the SearchResult struct as shown earlier
                let albumDetails = try decoder.decode(DiscogsReleaseDetails.self, from: data)
                
                let album = Album(
                    title: albumDetails.title,
                    artistID: albumDetails.artists.map {$0.id},
                    artistNames: albumDetails.artists.map {$0.name},
                    genres: albumDetails.genres ?? [],
                    styles: albumDetails.styles ?? [],
                    year: albumDetails.year,
                    albumTracks: albumDetails.tracklist.map { $0.title},
                    coverImageURL: albumDetails.images.first?.uri ?? ""
                )
                
                self.storeAlbum(album)
//                completion(.success(album))
                
                // Print the entire JSON data
//                print(albumDetails)
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }

        // Start the task
        task.resume()
    }
    
}

struct TrendingAlbum {
    let title: String
    let artist: String
}

struct DiscogsSearchResponse: Decodable {
    let results: [DiscogsAlbum]
}

struct DiscogsAlbum: Decodable {
    let master_id: Int
    let id: Int
    let title: String
}

struct DiscogsReleaseDetails: Decodable {
//    let id: Int
    let title: String
    let artists: [AlbumArtists]
    let genres: [String]?
    let styles: [String]?
    let year: Int
    let tracklist: [MusicTrack]
    let images: [AlbumCover]
    
    struct MusicTrack: Decodable {
        let title: String
    }
    
    struct AlbumCover: Decodable {
        let uri: String
    }
    
    struct AlbumArtists: Decodable {
        let name: String
        let id: Int
    }
}

