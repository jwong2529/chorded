//
//  ProfileImageManager.swift
//  Chorded
//
//  Created by Janice Wong on 8/6/24.
//

import Foundation
import SwiftUI
import _PhotosUI_SwiftUI
import Firebase
import FirebaseStorage

class ProfileImageManager: ObservableObject {
    @Published var uploadProgress: Double = 0.0
    @Published var isUploading: Bool = false
    
    func uploadProfileImage(_ image: UIImage?, forUser uid: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image?.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "Invalid Image", code: -1, userInfo: nil)))
            return
        }
        
        let storageRef = Storage.storage().reference().child("profile_images/\(uid).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        isUploading = true
        let uploadTask = storageRef.putData(imageData, metadata: metadata)
        
        uploadTask.observe(.progress) { snapshot in
            if let progress = snapshot.progress {
                self.uploadProgress = progress.fractionCompleted
            }
        }
        
        uploadTask.observe(.success) { snapshot in
            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    self.isUploading = false
                    return
                }
                guard let url = url else {
                    completion(.failure(NSError(domain: "URL Not Found", code: -1, userInfo: nil)))
                    self.isUploading = false
                    return
                }
                self.saveProfileImageURL(url.absoluteString, forUser: uid, completion: completion)
            }
        }
        
        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error {
                completion(.failure(error))
            }
            self.isUploading = false
        }
    }
    
    private func saveProfileImageURL(_ url: String, forUser uid: String, completion: @escaping (Result<String, Error>) -> Void) {
        let ref = Database.database().reference().child("Users/\(uid)/userProfilePictureURL")
        
        ref.setValue(url) { error, _ in
            self.isUploading = false
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(url))
            }
        }
    }
}
