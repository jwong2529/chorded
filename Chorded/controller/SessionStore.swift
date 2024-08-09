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
    @Published var isCheckingLogin: Bool = true // Add this line
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
            self.isCheckingLogin = false 
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            completion(error)
        }
    }
    
    func signUp(email: String, password: String, username: String, normalizedUsername: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let user = authResult?.user {
//                self.createUserInDatabase(uid: user.uid, email: email, username: username)
                FirebaseUserDataManager().createUser(uid: user.uid, email: email, username: username, normalizedUsername: normalizedUsername)
            }
            completion(error)
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

