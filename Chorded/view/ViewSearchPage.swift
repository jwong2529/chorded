//
//  ViewSearch.swift
//  MusicReviewApp
//
//  Created by Janice Wong on 5/25/24.
//

import Foundation
import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct ViewSearchPage: View {
    @State private var searchText = ""
    @State private var albums = [AlbumIndex]()
    @State private var artists = [ArtistIndex]()
    @State private var selectedTab = 0 //0 for albums, 1 for artists
    private var databaseRef: DatabaseReference = Database.database().reference()

    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                VStack (spacing: 5) {
                    ViewSearchTabBar(selectedTab: $selectedTab)
                        .padding(.top, 5)
                    
                    if selectedTab == 0 {
                        // Display albums
                        if !albums.isEmpty {
                            List(albums.prefix(5)) { album in
                                NavigationLink(destination: ViewAlbumPage(albumKey: album.id)) {
                                    HStack {
                                        if let url = URL(string: album.coverImageURL) {
                                            WebImage(url: url)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 50, height: 50)
                                                .clipped()
                                                .cornerRadius(10)
                                                .shadow(radius: 5)
                                        } else {
                                            PlaceholderAlbumCover(width: 50, height: 50)
                                        }
                                        VStack(alignment: .leading) {
                                            Text(album.title)
                                                .font(.headline)
                                        }
                                    }
                                }
                                .listRowBackground(Color.gray.opacity(0.2))
                            }
                            .listStyle(InsetGroupedListStyle())
                            .padding(.top, -20)
                            .background(Color.gray.opacity(0.2))
                            .scrollContentBackground(.hidden)
//                            Spacer()
                        } else {
                            Spacer()
                        }
                    } else {
                        // Display artists
                        if !artists.isEmpty {
                            List(artists.prefix(5)) { artist in
                                NavigationLink(destination: ViewArtistPage(artistID: artist.id)) {
                                    HStack {
                                        if let url = URL(string: artist.profilePicture) {
                                            WebImage(url: url)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 50, height: 50)
                                                .clipShape(Circle())
                                        } else {
                                            PlaceholderArtistImage(width: 50, height: 50)
                                        }
                                        VStack(alignment: .leading) {
                                            Text(artist.name)
                                                .font(.headline)
                                        }
                                    }
                                }
                                .listRowBackground(Color.gray.opacity(0.2))
                            }
                            .listStyle(InsetGroupedListStyle())
                            .padding(.top, -20)
                            .background(Color.gray.opacity(0.2))
                            .scrollContentBackground(.hidden)
//                            Spacer()
                        } else {
                            Spacer()
                        }
                    }

                }
//                .padding(.top)
                .searchable(text: $searchText, prompt: "Search \(selectedTab == 0 ? "albums" : "artists")")
                .onChange(of: searchText) { newValue in
                    if selectedTab == 0 {
                        searchAlbums(with: newValue)
                    } else {
                        searchArtists(with: newValue)
                    }
                }
            }
            .navigationBarTitle("Search for music", displayMode: .inline)
        }
    }
    
    func searchAlbums(with query: String) {
        let fixedQuery = FixStrings().normalizeString(query)
        guard !fixedQuery.isEmpty else {
            self.albums = []
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
            self.albums = newAlbums
        }
    }
    
    func searchArtists(with query: String) {
//        print("are you here")
        let fixedQuery = FixStrings().normalizeString(query)
        guard !fixedQuery.isEmpty else {
            self.artists = []
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
            self.artists = newArtists
        }
        
    }
}


//#Preview {
//    ViewSearchPage()
//}
