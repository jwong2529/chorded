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
    
    // ALBUMS
    
    func searchAlbum(albumName: String, artistName: String, completion: @escaping (Result<Album, Error>) -> Void) {

        let query = "q=\"\(albumName)\"&artist=\(artistName)&type=master&format=album"
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error encoding URL components"])))
            return
        }
        
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
                    self.fetchAlbumDetails(discogsAlbum: discogsAlbum, completion: completion)
                } else {
                    // If no album found, try another query
                    let alternateQuery = "release_title=\(albumName)&q=\(artistName)"
                    guard let encodedAlternateQuery = alternateQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error encoding URL components"])))
                        return
                    }
                    
                    let alternateSearchURL = URL(string: "\(self.baseURL)database/search?\(encodedAlternateQuery)&per_page=1&page=1&\(self.apiCredsString)")!
                    
                    URLSession.shared.dataTask(with: alternateSearchURL) { data, response, error in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        guard let data = data else {
                            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                            return
                        }
                        do {
                            let alternateSearchResponse = try JSONDecoder().decode(DiscogsSearchResponse.self, from: data)
                            if let alternateDiscogsAlbum = alternateSearchResponse.results.first {
                                self.fetchAlbumDetails(discogsAlbum: alternateDiscogsAlbum, completion: completion)
                            } else {
                                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No album found"])))
                            }
                        } catch {
                            completion(.failure(error))
                        }
                    }.resume()
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    
    func fetchAlbumDetails(discogsAlbum: DiscogsAlbum, completion: @escaping (Result<Album, Error>) -> Void) {
        
        //set the id num to master id unless it's equal to 0
        
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
                
                //fix the artist name part if needed
                var truncatedArtistNames = [String]()
                for artist in albumDetails.artists {
                    let newArtistName = FixStrings().deleteDistinctArtistNum(artist.name)
                    truncatedArtistNames.append(newArtistName)
                }
                
                let album = Album(
                    title: albumDetails.title,
                    artistID: albumDetails.artists.map {$0.id},
                    artistNames: truncatedArtistNames.map {$0},
                    genres: albumDetails.genres ?? [],
                    styles: albumDetails.styles ?? [],
                    year: albumDetails.year,
                    albumTracks: albumDetails.tracklist.map { $0.title},
                    coverImageURL: albumDetails.images?.first?.uri ?? ""
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
    
    // ARTISTS
    
    func fetchArtistDetails(artistID: Int, completion: @escaping (Result<Artist, Error>) -> Void) {
        let urlString = "\(baseURL)artists/\(artistID)?\(apiCredsString)"
        guard let artistURL = URL(string: urlString) else {
            print("Invalid URL")
            exit(1)
        }
        
        var request = URLRequest(url: artistURL)
        request.setValue("Chorded/1.0", forHTTPHeaderField: "User-Agent")
        
        let task = URLSession.shared.dataTask(with: artistURL) { data, response, error in
            if let error = error {
                completion(.failure(error))
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            do {
//                print("Received data: \(String(data: data, encoding: .utf8) ?? "Invalid data")")

                let artistDetails = try JSONDecoder().decode(DiscogsArtistDetails.self, from: data)
                
                let truncatedArtistName = FixStrings().deleteDistinctArtistNum(artistDetails.name)
                
                let artist = Artist(
                    name: truncatedArtistName,
                    profileDescription: artistDetails.profile ?? "",
                    discogsID: artistDetails.id,
                    imageURL: artistDetails.images?.first?.uri ?? ""
                )
                completion(.success(artist))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    private func cleanString(_ input: String) -> String {
        let allowedCharacters = CharacterSet.alphanumerics.union(CharacterSet.whitespaces)
        return input.unicodeScalars.filter { allowedCharacters.contains($0) }.map { String($0) }.joined()
    }
    
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
    let images: [AlbumCover]?
    
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

struct DiscogsArtistDetails: Decodable {
    let name: String
    let profile: String?
    let id: Int
    let images: [ArtistPhoto]?
    
    struct ArtistPhoto: Decodable {
        let uri: String
    }
}

