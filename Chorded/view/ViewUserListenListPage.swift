//
//  ViewUserListenListPage.swift
//  Chorded
//
//  Created by Janice Wong on 8/6/24.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI

struct ViewUserListenListPage: View {
    var userID: String
    @State private var userListenList: [String] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                ScrollView() {
                    VStack {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                            ForEach(userListenList, id: \.self) { albumID in
                                UserListenListAlbumView(albumID: albumID)
                            }
                        }
                    }
                    .padding()
                    .onAppear() {
                        fetchUserListenList()
                    }
                    .refreshable {
                        fetchUserListenList()
                    }
                    .navigationBarTitle("Listen List", displayMode: .inline)
                }
            }
        }
    }
    
    private func fetchUserListenList() {
        FirebaseUserData().fetchUserListenList(uid: userID) { userListenList in
            self.userListenList = userListenList
        }
    }
}

struct UserListenListAlbumView: View {
    var albumID: String
    @State private var album: Album = Album(title: "", artistID: [0], artistNames: [""], genres: [], styles: [], year: 0, albumTracks: [""], coverImageURL: "")
    
    var body: some View {
        VStack {
            NavigationLink(destination: ViewAlbumPage(albumKey: album.firebaseKey)) {
                if album.coverImageURL != "", let url = URL(string: album.coverImageURL) {
                    WebImage(url: url)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipped()
                        .cornerRadius(10)
                        .shadow(radius: 5)
                } else {
                    PlaceholderAlbumCover(width: 100, height: 100)
                }
            }
            Spacer()
        }
        .onAppear() {
            fetchAlbum()
        }
    }
    
    private func fetchAlbum() {
        FirebaseDataManager().fetchAlbum(firebaseKey: albumID) { fetchedAlbum, error in
            if let error = error {
                print("Failed to fetch album: \(error.localizedDescription)")
            } else if let fetchedAlbum = fetchedAlbum {
                self.album = fetchedAlbum
            }
        }
    }
}
