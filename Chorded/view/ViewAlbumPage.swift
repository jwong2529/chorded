//
//  ViewAlbumPage.swift
//  Chorded
//
//  Created by Janice Wong on 6/6/24.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI

struct ViewAlbumPage: View {
//    @State private var album: Album
    @State private var showTracklist = false
    @State private var ratingProgress: CGFloat = 0.0
    @State var selection1: String? = "Tracklist"
    let album: Album
    @State private var artists = [Artist]()

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                ScrollView {
                    VStack(spacing: 20) {
                        WebImage(url: URL(string: album.coverImageURL))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 200, height: 200)
                            .shadow(color: .blue, radius: 5)
                            .padding(.top, 20)
                        
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(album.title)
                                    .font(.system(size: 27, weight: .bold, design: .default))
                                    .foregroundColor(.white)
                                HStack(spacing: 10) {
                                    Text(album.artistNames.joined(separator: ", "))
                                        .foregroundColor(.white)
                                    Circle()
                                        .fill(Color.gray)
                                        .frame(width: 5, height: 5)
                                    Text(String(album.year))
                                        .foregroundColor(.gray)
                                }
                            }
                            Spacer()
                            ZStack {
                                RatingRing(rating: $ratingProgress)
                                    .frame(width: 50, height: 50)
                            }
                            .padding(.leading)
                                
                        }
                        .padding(.horizontal)
                        
                        DropdownList(
                            selection: $selection1,
                            options: album.albumTracks
                        )
                        .padding(.horizontal)
                        
                        // later, group the listened by and wants to listen parts and put in another class and only display if users have friends that have this album in their list
                        NavigationLink(destination: ViewReviewPage()) {
                            HStack {
                                Text("Listened By")
                                    .font(.system(size: 20, weight: .medium, design: .default))
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.blue)
                            }
                            .contentShape(Rectangle())
                            .padding(.horizontal)
                        }
                        .buttonStyle(HighlightButtonStyle())
                        HStack(alignment: .top) {
                            HStack(spacing: 15) {
                                ForEach(0..<4) { _ in
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .foregroundColor(.gray)
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                        .padding(.trailing, 10)
                                }
                            }
                            .padding(.horizontal)
                            Spacer()
                        }
                        
                        NavigationLink(destination: ViewReviewPage()) {
                            HStack {
                                Text("Wants to Listen")
                                    .font(.system(size: 20, weight: .medium, design: .default))
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.blue)
                            }
                            .contentShape(Rectangle())
                            .padding(.horizontal)
                        }
                        .buttonStyle(HighlightButtonStyle())
                        HStack(alignment: .top) {
                            HStack(spacing: 15) {
                                ForEach(0..<4) { _ in
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .foregroundColor(.gray)
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                        .padding(.trailing, 10)
                                }
                            }
                            .padding(.horizontal)
                            Spacer()
                        }

                        NavigationLink(destination: ViewReviewPage()) {
                            HStack {
                                Text("Reviews - 0")
                                    .font(.system(size: 20, weight: .medium, design: .default))
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.blue)
                            }
                            .contentShape(Rectangle())
                            .padding()
                            .background(.purple.opacity(0.7))
                            .cornerRadius(25)
                        }
                        .buttonStyle(HighlightButtonStyle())
                        .padding()
                        
                        ViewAlbumPageMiniBar(artists: artists, album: album)
                        
                    }
                }
            }
        }
        .onAppear {
            fetchArtists(discogsKeys: album.artistID)
        }
    }
    
    func fetchArtists(discogsKeys: [Int]) {
        let dispatchGroup = DispatchGroup()
        var fetchedArtists: [Artist] = []
        var fetchError: Error?
        
        for discogsKey in discogsKeys {
            dispatchGroup.enter()
            FirebaseDataManager().fetchArtist(discogsKey: discogsKey) { artist, error in
                defer {
                    dispatchGroup.leave()
                }
                if let artist = artist {
                    fetchedArtists.append(artist)
                } else if let error = error {
                    fetchError = error
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            if fetchError != nil {
                print("Couldn't fetch artists to display on album page")
            } else {
                self.artists = fetchedArtists
            }
        }
    }
}


//#Preview {
//    ViewAlbumPage()
//}


