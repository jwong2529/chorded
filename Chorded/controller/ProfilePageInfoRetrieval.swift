//
//  ProfilePageInfoRetrieval.swift
//  Chorded
//
//  Created by Janice Wong on 8/6/24.
//

import Foundation
import Firebase

class ProfilePageInfoRetrieval {
    private let databaseRef: DatabaseReference
    
    init() {
        databaseRef = Database.database().reference()
    }
    
    func fetchFollowingAndFollowersCount(userID: String, completion: @escaping (Int, Int, Error?) -> Void) {
        let followingRef = databaseRef.child("UserConnections").child(userID).child("Following")
        let followersRef = databaseRef.child("UserConnections").child(userID).child("Followers")
        
        let dispatchGroup = DispatchGroup()
        
        var followingCount = 0
        var followersCount = 0
        var fetchError: Error?
        
        dispatchGroup.enter()
        followingRef.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                followingCount = Int(snapshot.childrenCount)
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        followersRef.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                followersCount = Int(snapshot.childrenCount)
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(followingCount, followersCount, fetchError)
        }
        
    }
    
    func fetchAlbumReviewsWithTextCount(userID: String, completion: @escaping (Int, Int, Error?) -> Void) {
        FirebaseUserDataManager().fetchUserReviews(uid: userID) { userReviews, error in
            if let error = error {
                completion(0, 0, error)
                return
            }
            
            guard let userReviews = userReviews else {
                completion(0, 0, nil)
                return
            }
            
            let count = userReviews.count
            let withTextCount = userReviews.filter { !$0.reviewText.isEmpty }.count
            completion(count, withTextCount, nil)
        }
    }
    
    func fetchListenListCount(userID: String, completion: @escaping (Int?, Error?) -> Void) {
        let listenListRef = databaseRef.child("UserListenList").child(userID)
        
        listenListRef.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                let listenListCount = snapshot.childrenCount
                completion(Int(listenListCount), nil)
            } else {
                completion(0, nil)
            }
        }
    }
    
}
