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
    @Published var currentUserID: String? = nil
    private var handle: AuthStateDidChangeListenerHandle?
    
    init() {
        listen()
    }
    
    func listen() {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                self.isLoggedIn = true
                self.currentUserID = user.uid
                print("User is logged in with ID: \(user.uid)")
            } else {
                self.isLoggedIn = false
                self.currentUserID = nil
                print("User is not logged in")
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            completion(error)
        }
    }
    
    func signUp(email: String, password: String, username: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let user = authResult?.user {
                self.createUserInDatabase(uid: user.uid, email: email, username: username)
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
            self.currentUserID = nil
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

