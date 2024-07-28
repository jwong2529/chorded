//
//  SessionStore.swift
//  Chorded
//
//  Created by Janice Wong on 7/24/24.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseDatabase

class SessionStore: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User?
    @Published var userConnections: UserConnections?
    @Published var userReviews: UserReviews?
    @Published var userListenList: UserListenList?
    
    private var handle: AuthStateDidChangeListenerHandle?
    
    init() {
        listen()
    }
    
    func listen() {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                self.isLoggedIn = true
                self.fetchUserData(uid: user.uid)
            } else {
                self.isLoggedIn = false
                self.currentUser = nil
                self.userConnections = nil
                self.userReviews = nil
                self.userListenList = nil
            }
        }
    }
    
    func fetchUserData(uid: String) {
        let userRef = Database.database().reference().child("Users").child(uid)
        userRef.observeSingleEvent(of: .value) { snapshot in
            if let data = snapshot.value as? [String: Any] {
                self.currentUser = User.fromDictionary(data)
                self.fetchUserConnections(uid: uid)
                self.fetchUserReviews(uid: uid)
                self.fetchUserListenList(uid: uid)
            }
        }
    }
    
    func fetchUserConnections(uid: String) {
        let connectionsRef = Database.database().reference().child("UserConnections").child(uid)
        connectionsRef.observeSingleEvent(of: .value) { snapshot in
            if let data = snapshot.value as? [String: Any] {
                self.userConnections = UserConnections.fromDictionary(data)
            }
        }
    }
    
    func fetchUserReviews(uid: String) {
        let reviewsRef = Database.database().reference().child("UserReviews").child(uid)
        reviewsRef.observeSingleEvent(of: .value) { snapshot in
            if let data = snapshot.value as? [String: Any] {
                self.userReviews = UserReviews.fromDictionary(data)
            }
        }
    }

    func fetchUserListenList(uid: String) {
        let listenListRef = Database.database().reference().child("UserListenList").child(uid)
        listenListRef.observeSingleEvent(of: .value) { snapshot in
            if let data = snapshot.value as? [String: Any] {
                self.userListenList = UserListenList.fromDictionary(data)
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let user = authResult?.user {
                self.fetchUserData(uid: user.uid)
            }
            completion(error)
        }
    }
    
    func signUp(email: String, password: String, username: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let user = authResult?.user {
                self.createUserInDatabase(uid: user.uid, email: email, username: username)
                self.fetchUserData(uid: user.uid)
            }
            completion(error)
        }
    }
    
    private func createUserInDatabase(uid: String, email: String, username: String) {
        let userRef = Database.database().reference().child("Users").child(uid)
        let user = User(id: uid, username: username, email: email, profilePictureURL: "")
        
        userRef.setValue(user.toDictionary()) { error, _ in
            if let error = error {
                print("Error saving user to database: \(error.localizedDescription)")
            }
        }
                      
        let connectionsRef = Database.database().reference().child("UserConnections").child(uid)
        let connections = UserConnections(id: uid)
        
        connectionsRef.setValue(connections.toDictionary()) { error, _ in
            if let error = error {
                print("Error saving user connections to database: \(error.localizedDescription)")
            }
        }
        
        let reviewsRef = Database.database().reference().child("UserReviews").child(uid)
        let reviews = UserReviews(id: uid)
        
        reviewsRef.setValue(reviews.toDictionary()) { error, _ in
            if let error = error {
                print("Error saving user reviews to database: \(error.localizedDescription)")
            }
        }
        
        let listenListRef = Database.database().reference().child("UserListenList").child(uid)
        let listenList = UserListenList(id: uid)
        
        listenListRef.setValue(listenList.toDictionary()) { error, _ in
            if let error = error {
                print("Error saving user listen list to database: \(error.localizedDescription)")
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.isLoggedIn = false
            self.currentUser = nil
            self.currentUser = nil
            self.userConnections = nil
            self.userReviews = nil
            self.userListenList = nil
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}

extension Encodable {
    func toDictionary() -> [String: Any] {
        guard let data = try? JSONEncoder().encode(self),
              let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            return [:]
        }
        return dictionary
    }
}

extension User {
    static func fromDictionary(_ dictionary: [String: Any]) -> User? {
        guard let id = dictionary["id"] as? String,
              let username = dictionary["username"] as? String,
              let email = dictionary["email"] as? String,
              let profilePictureURL = dictionary["profilePictureURL"] as? String else {
            return nil
        }
        return User(id: id, username: username, email: email, profilePictureURL: profilePictureURL)
    }
}

extension UserConnections {
    static func fromDictionary(_ dictionary: [String: Any]) -> UserConnections? {
        guard let id = dictionary["id"] as? String,
              let following = dictionary["following"] as? [String],
              let followers = dictionary["followers"] as? [String] else {
            return nil
        }
        return UserConnections(id: id, following: following, followers: followers)
    }
}

extension UserReviews {
    static func fromDictionary(_ dictionary: [String: Any]) -> UserReviews? {
        guard let id = dictionary["id"] as? String,
              let albumReviews = dictionary["albumReviews"] as? [String] else {
            return nil
        }
        return UserReviews(id: id, albumReviews: albumReviews)
    }
}

extension UserListenList {
    static func fromDictionary(_ dictionary: [String: Any]) -> UserListenList? {
        guard let id = dictionary["id"] as? String,
              let listenList = dictionary["listenList"] as? [String] else {
            return nil
        }
        return UserListenList(id: id, listenList: listenList)
    }
}
