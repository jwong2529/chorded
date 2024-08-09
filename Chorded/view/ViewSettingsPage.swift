//
//  ViewEditProfilePage.swift
//  Chorded
//
//  Created by Janice Wong on 8/4/24.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI
import _PhotosUI_SwiftUI
import UIKit


struct ViewSettingsPage: View {
    var user: User
    @EnvironmentObject var session: SessionStore
    @Environment(\.presentationMode) var presentationMode
    
    @State private var originalUsername: String = ""
    @State private var usernameText: String = ""
    
    @State private var originalBio: String = ""
    @State private var bioText: String = ""
    
    @State private var originalAlbumFavorites: [String] = []
    @State private var albumFavorites: [String] = ["", "", ""]
    
    @State private var selectedPhotoPickerItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var selectedImage: UIImage?
    @State private var originalImageData: Data?
    
    @State private var showFavoritesSearchModal = false
    @State private var selectedAlbum: Album?
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    @StateObject private var profileImageManager = ProfileImageManager()
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                ScrollView {
                    VStack {
                        PhotosPicker(selection: $selectedPhotoPickerItem, matching: .images) {
                            if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFill()
                                    .clipShape(Circle())
                                    .frame(width: 100, height: 100)
                                    .shadow(radius: 10)
                                    .overlay(
                                        EditIconOverlay()
                                            .offset(x: 35, y: -40)
                                    )
                            } else if !user.userProfilePictureURL.isEmpty {
                                WebImage(url: URL(string: user.userProfilePictureURL))
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .shadow(color: .blue, radius: 5)
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .shadow(radius: 10)
                                    .overlay(
                                        EditIconOverlay()
                                            .offset(x: 35, y: -40)
                                    )
                            } else {
                                PlaceholderUserImage(width: 100, height: 100)
                                    .shadow(radius: 10)
                                    .overlay(
                                        EditIconOverlay()
                                            .offset(x: 35, y: -40)
                                    )
                            }
                        }
                        .onChange(of: selectedPhotoPickerItem) { newItem in
                            if let newItem = newItem {
                                loadImage(from: newItem)
                            }
                        }
                        
                        if profileImageManager.isUploading {
                            ProgressView(value: profileImageManager.uploadProgress)
                                .padding(.horizontal)
                        }
                        
                        // edit user information
                        VStack(alignment: .leading) {
                            Text("Profile")
                                .font(.headline)
                                .foregroundColor(.white)
//                                .padding()
                            VStack(alignment: .leading) {
                                HStack(alignment: .top) {
                                    Text("Username")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                    TextField("\(originalUsername)", text: $usernameText)
                                        .font(.body)
                                        .padding(5)
                                        .autocapitalization(.none)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(6)

                                    Spacer()
                                }
                                Divider().overlay(Color.white)
                                HStack(alignment: .top) {
                                    Text("Bio")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                    TextEditor(text: $bioText)
                                        .font(.body)
                                        .autocapitalization(.none)
                                        .lineLimit(3)
                                        .frame(minHeight: 75, maxHeight: 75)
                                        .scrollContentBackground(.hidden)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(6)
                                        .lineSpacing(3)
                                    Spacer()
                                }
                                
                            }
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(6)
                        }
                        
                        Divider().overlay(Color.white)
                        
                        // favorite albums
                        VStack(alignment: .leading) {
                            Text("Favorite Albums")
                                .font(.headline)
                                .foregroundColor(.white)
                            HStack(spacing: 15) {
                                Spacer()
                                ForEach(albumFavorites, id: \.self) { albumKey in
                                    if albumKey != "" {
                                        FavoriteAlbumsSlot(albumKey: albumKey)
                                        .overlay(
                                            Button(action: {
                                                removeFavoriteAlbum(keyToDelete: albumKey)
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.red)
                                                    .background(Color.white)
                                                    .clipShape(Circle())
                                                    .padding(5)
                                            }
                                            .offset(x: 10, y: -10),
                                            alignment: .topTrailing
                                        )
                                    } else {
                                        EmptyFavoriteAlbumsPlaceholder()
                                            .onTapGesture {
                                                self.showFavoritesSearchModal = true
                                            }
                                    }
                                }
                                Spacer()
                            }
                            .onChange(of: selectedAlbum) { newValue in
                                if let newAlbum = newValue {
                                    if !albumFavorites.contains(newAlbum.firebaseKey) {
                                        if let index = albumFavorites.firstIndex(of: "") {
                                            albumFavorites[index] = newAlbum.firebaseKey
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .sheet(isPresented: $showFavoritesSearchModal) {
                ViewFavoritesSearchPage(user: user, showModal: $showFavoritesSearchModal, selectedAlbum: $selectedAlbum)
            }
        }
        .navigationBarTitle("Settings", displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
            // save settings
            saveSettings()
        }) {
            Text("Save")
                .padding(3)
                .foregroundColor(Color.green)
        })
        .onAppear() {
            fetchData()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(""), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func fetchData() {
        populateFields()
    }
    
    private func populateFields() {
        originalUsername = user.username
        usernameText = user.username
        originalBio = user.userBio
        bioText = user.userBio
        originalAlbumFavorites = user.userAlbumFavorites ?? []
        albumFavorites = user.userAlbumFavorites ?? ["", "", ""]
        
        loadOriginalProfileImage()
    }
    
    private func saveSettings() {
        //validate username
        var newUsername = originalUsername
        var newNormalizedUsername = user.normalizedUsername
        if originalUsername != usernameText {
            if validateUsername(username: usernameText) {
                newUsername = usernameText
                newNormalizedUsername = FixStrings().normalizeString(newUsername)
            } else {
                alertMessage = "Username must be one word, between 3 and 30 characters, and not contain .$#[]/"
                showAlert = true
                return
            }
        }
    
        //validate bio
        var newBio = originalBio
        if originalBio != bioText {
            if validateBio(bio: bioText) {
                newBio = bioText
            } else {
                alertMessage = "Bio cannot exceed 90 characters"
                showAlert = true
                return
            }
        }
        
        var newAlbumFavorites = originalAlbumFavorites
        if originalAlbumFavorites != albumFavorites {
            newAlbumFavorites = albumFavorites
        }
        
        // check if profile picture has changed
        if let selectedImage = selectedImage,
           let selectedImageData = selectedImage.jpegData(compressionQuality: 1.0),
           selectedImageData != originalImageData {
            uploadProfileImage()
        } else {
            print("No changes to the profile image.")
        }
        
        FirebaseUserDataManager().updateUserData(userID: user.userID, newUsername: newUsername, newNormalizedUsername: newNormalizedUsername, newBio: newBio, newAlbumFavorites: newAlbumFavorites) { result in
            switch result {
            case .success():
                print("User data updated successfully.")
                alertMessage = "Updated profile!"
                showAlert = true
                self.presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                print("Failed to update user data: \(error.localizedDescription)")
            }
        }
        
    }
    
    private func validateUsername(username: String) -> Bool {
        let invalidCharacters = CharacterSet(charactersIn: ".S#[]/")
        let whitespaceCharacters = CharacterSet.whitespaces

        if username.rangeOfCharacter(from: invalidCharacters) != nil {
            return false
        } 
        
        if username.rangeOfCharacter(from: whitespaceCharacters) != nil {
            return false
        }
        
        else {
            return username.count >= 3 && username.count <= 30
        }
    }
    
    private func validateBio(bio: String) -> Bool {
        return bio.count <= 90
    }
    
    private func loadOriginalProfileImage() {
        if let url = URL(string: user.userProfilePictureURL) {
            loadImage(from: url) { image in
                if let image = image {
                    originalImageData = image.jpegData(compressionQuality: 1.0)
                }
            }
        }
    }
    
    private func loadImage(from item: PhotosPickerItem) {
        item.loadTransferable(type: Data.self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let data = data, let uiImage = UIImage(data: data) {
                        selectedImage = uiImage
                    }
                case .failure(let error):
                    print("Error loading image: \(error)")
                }
            }
        }
    }
    
    
    //converts from url to image
    private func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    private func uploadProfileImage() {
        guard let uid = session.currentUserID else { return }
        
        profileImageManager.uploadProfileImage(selectedImage, forUser: uid) { result in
            switch result {
            case .success(let url):
                print("Successfully saved URL to database: \(url)")
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    private func removeFavoriteAlbum(keyToDelete: String) {
        // filter out the key to delete and move all albums to the front to get rid of empty spaces
        albumFavorites = albumFavorites.filter { $0 != keyToDelete }
        while albumFavorites.count < 3 {
            albumFavorites.append("")
        }
    }

}


struct EditIconOverlay: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 20, height: 20)
                .shadow(radius: 5)
            Image(systemName: "pencil")
                .foregroundColor(.blue)
        }
    }
}

struct FavoriteAlbumsSlot: View {
    var albumKey: String
    @State private var album: Album = Album(title: "", artistID: [0], artistNames: [""], genres: [], styles: [], year: 0, albumTracks: [""], coverImageURL: "")
    @State private var albumSize: CGFloat = 90
    
    var body: some View {
        VStack {
            if album.coverImageURL != "", let url = URL(string: album.coverImageURL) {
                WebImage(url: url)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: albumSize, height: albumSize)
                    .clipped()
                    .cornerRadius(10)
            } else {
                PlaceholderAlbumCover(width: albumSize, height: albumSize)
            }
        }
        .onAppear() {
            fetchAlbum()
        }
    }
    
    private func fetchAlbum() {
        if !albumKey.isEmpty {
            FirebaseDataManager().fetchAlbum(firebaseKey: albumKey) { fetchedAlbum, error in
                if let error = error {
                    print("Failed to fetch album: \(error.localizedDescription)")
                } else if let fetchedAlbum = fetchedAlbum {
                    self.album = fetchedAlbum
                }
            }
        }
    }
}

struct EmptyFavoriteAlbumsPlaceholder: View {
    @State private var albumSize: CGFloat = 90

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: albumSize, height: albumSize)
                .cornerRadius(10)
            Image(systemName: "plus")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: albumSize * 0.2, height: albumSize * 0.2)
                .foregroundColor(.gray)
        }
    }
}
