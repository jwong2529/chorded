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
    @State private var users = [User]()
    @State private var selectedTab = 0 //0 for albums, 1 for artists, 2 for users
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
                        displayAlbums()
                    } else if selectedTab == 1 {
                        displayArtists()
                    } else if selectedTab == 2 {
                        displayUsers()
                    } else {
                        
                    }
                }
                .searchable(text: $searchText, prompt: Text(searchPrompt))
                .onChange(of: searchText) { newValue in
                    performSearch(with: newValue)
                }
            }
            .navigationBarTitle("Search", displayMode: .inline)
        }
    }
    
    private var searchPrompt: String {
        switch selectedTab {
        case 0: return "Search albums"
        case 1: return "Search artists"
        case 2: return "Search Users"
        default: return ""
        }
    }
    
    private func performSearch(with query: String) {
        switch selectedTab {
        case 0:
            SearchData().searchAlbums(with: query) { results in
                self.albums = results
            }
        case 1:
            SearchData().searchArtists(with: query) { results in
                self.artists = results
            }
        case 2:
            SearchData().searchUsers(with: query) { results in
                self.users = results
            }
        default:
            return
        }
    }
    
    @ViewBuilder
    private func displayAlbums() -> some View {
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
        } else {
            Spacer()
        }
    }
    
    @ViewBuilder
    private func displayArtists() -> some View {
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
        } else {
            Spacer()
        }
    }
    
    @ViewBuilder
    private func displayUsers() -> some View {
        if !users.isEmpty {
            List(users.prefix(5), id: \.userID) { user in
                NavigationLink(destination: ViewProfilePage(userID: user.userID)) {
                    HStack {
                        if let url = URL(string: user.userProfilePictureURL) {
                            WebImage(url: url)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                        } else {
                            PlaceholderUserImage(width: 50, height: 50)
                        }
                        VStack(alignment: .leading) {
                            Text(user.username)
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
        } else {
            Spacer()
        }
    }
}


//#Preview {
//    ViewSearchPage()
//}
