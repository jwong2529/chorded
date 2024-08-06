import Foundation
import FirebaseDatabase

class FirebaseUserData {
    private let databaseRef: DatabaseReference
    
    init() {
        databaseRef = Database.database().reference()
    }
    
    func createUser(uid: String, email: String, username: String, normalizedUsername: String) {
        let userRef = databaseRef.child("Users").child(uid)
        let user = User(userID: uid, username: username, normalizedUsername: normalizedUsername, email: email, userProfilePictureURL: "", userBio: "")
        
        userRef.setValue(user.toDictionary()) { error, _ in
            if let error = error {
                print("Error saving user to database: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchUserData(uid: String, completion: @escaping (User?, Error?) -> Void) {
        let userRef = databaseRef.child("Users").child(uid)
        userRef.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists(), let userData = snapshot.value as? [String: Any] else {
                completion(nil, NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found in Firebase"]))
                return
            }
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: userData, options: [])
                let user = try JSONDecoder().decode(User.self, from: jsonData)
                completion(user, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
    
    func fetchUserReview(currentUserID: String, albumID: String, completion: @escaping (AlbumReview?, Error?) -> Void) {
        let userReviewRef = databaseRef.child("UserReviews").child(currentUserID)
        
        userReviewRef.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists() else {
                completion(nil, nil)
                return
            }
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                if let reviewData = child.value as? [String: Any],
                   let albumKey = reviewData["albumKey"] as? String,
                   albumKey == albumID {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: reviewData)
                        let review = try JSONDecoder().decode(AlbumReview.self, from: jsonData)
                        completion(review, nil)
                        return
                    } catch {
                        completion(nil, error)
                        return
                    }
                } 
            }
            completion(nil, nil)
        }
    }
    
    func followUser(currentUserID: String, followedUserID: String) {
        databaseRef.child("UserConnections").child(currentUserID).child("Following").child(followedUserID).setValue(true)
        databaseRef.child("UserConnections").child(followedUserID).child("Followers").child(currentUserID).setValue(true)
    }
    
    func unfollowUser(currentUserID: String, unfollowedUserID: String) {
        databaseRef.child("UserConnections").child(currentUserID).child("Following").child(unfollowedUserID).removeValue()
        databaseRef.child("UserConnections").child(unfollowedUserID).child("Followers").child(currentUserID).removeValue()
    }
    
    func fetchUserConnections(uid: String, completion: @escaping (_ following: [String], _ followers: [String]) -> Void) {
        var followingList: [String] = []
        var followersList: [String] = []
        
        fetchFollowing(uid: uid) { fetchedFollowing in
            followingList = fetchedFollowing
            
            // Fetch followers only after fetching following is done
            self.fetchFollowers(uid: uid) { fetchedFollowers in
                followersList = fetchedFollowers
                
                // Call completion with both lists
                completion(followingList, followersList)
            }
        }
    }
    
    func fetchFollowers(uid: String, completion: @escaping (_ followers: [String]) -> Void) {
        let followersRef = databaseRef.child("UserConnections").child(uid).child("Followers")
        
        followersRef.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                if let followersData = snapshot.value as? [String: Bool] {
                    let followersList = Array(followersData.keys)
                    completion(followersList)
                } else {
                    // if the node exists but has no valid data
                    completion([])
                }
            } else {
                // if the "Followers" node does not exist
                completion([])
            }
        }
    }
    
    func fetchFollowing(uid: String, completion: @escaping (_ following: [String]) -> Void) {
        let followingRef = databaseRef.child("UserConnections").child(uid).child("Following")
        
        followingRef.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                if let followingData = snapshot.value as? [String: Bool] {
                    let followingList = Array(followingData.keys)
                    completion(followingList)
                } else {
                    // if the node exists but has no valid data
                    completion([])
                }
            } else {
                // if the "Following" node does not exist
                completion([])
            }
        }
    }
    
    
    func checkIfFollowing(currentUserID: String, otherUserID: String, completion: @escaping (_ isFollowing: Bool) -> Void) {
        let ref = databaseRef.child("UserConnections").child(currentUserID).child("Following").child(otherUserID)
        
        ref.observeSingleEvent(of: .value) { snapshot in
            completion(snapshot.exists())
        }
    }
    
    func fetchUserReviews(uid: String, completion: @escaping ([AlbumReview]?, Error?) -> Void) {
        let reviewsRef = databaseRef.child("UserReviews").child(uid)
        reviewsRef.queryOrdered(byChild: "reviewTimestamp").observeSingleEvent(of: .value) { snapshot in
            var userReviews: [AlbumReview] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let reviewData = snapshot.value as? [String: Any],
                   let albumReviewID = reviewData["albumReviewID"] as? String,
                   let userID = reviewData["userID"] as? String,
                   let albumKey = reviewData["albumKey"] as? String,
                   let rating = reviewData["rating"] as? Double,
                   let reviewText = reviewData["reviewText"] as? String,
                   let reviewTimestamp = reviewData["reviewTimestamp"] as? String {
                    let review = AlbumReview(albumReviewID: albumReviewID, userID: userID, albumKey: albumKey, rating: rating, reviewText: reviewText, reviewTimestamp: reviewTimestamp)
                    userReviews.append(review)
                }
            }
            
            completion(userReviews, nil)
        }
    }
    
    func addToListenList(currentUserID: String, albumID: String) {
        // add to listen list
        databaseRef.child("UserListenList").child(currentUserID).child(albumID).setValue(true)
        
        // log activity
        let activityID = UUID().uuidString
        let timestamp = ISO8601DateFormatter().string(from: Date())

        let activity = Activity(
            activityID: activityID,
            userID: currentUserID,
            activityTimestamp: timestamp,
            activityType: .listenList,
            albumID: albumID,
            albumReviewID: nil
        )
        
        logActivity(activity: activity) { error in
            if let error = error {
                print("Error logging addToListenList as activity: \(error.localizedDescription)")
            }
        }
    }
    
    func removeFromListenList(currentUserID: String, albumID: String) {
        // remove from listen list
        databaseRef.child("UserListenList").child(currentUserID).child(albumID).removeValue()
        
        // removing the activity
        let userActivitiesRef = databaseRef.child("UserActivities").child(currentUserID)
        userActivitiesRef.queryOrdered(byChild: "albumID").queryEqual(toValue: albumID).observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let activityData = childSnapshot.value as? [String: Any],
                   let activityType = activityData["activityType"] as? String,
                   activityType == ActivityType.listenList.rawValue {
                    let activityID = childSnapshot.key
                    
                    //remove activity
                    self.databaseRef.child("ActivityLog").child(activityID).removeValue()
                    self.databaseRef.child("UserActivities").child(currentUserID).child(activityID).removeValue()
                }
            }
        }
    }
    
    func isInListenList(uid: String, albumID: String, completion: @escaping (_ inListenList: Bool) -> Void) {
        let listenListRef = databaseRef.child("UserListenList").child(uid).child(albumID)
        
        listenListRef.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func fetchUserListenList(uid: String, completion: @escaping (_ listenList: [String]) -> Void) {
        let listenListRef = databaseRef.child("UserListenList").child(uid)
        
        listenListRef.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                if let listenListData = snapshot.value as? [String: Bool] {
                    let listenList = Array(listenListData.keys)
                    completion(listenList)
                } else {
                    completion([])
                }
            } else {
                completion([])
            }
        }
    }
    
    func logActivity(activity: Activity, completion: @escaping (Error?) -> Void) {
        let activityLogRef = databaseRef.child("ActivityLog").child(activity.activityID)
        let userActivityRef = databaseRef.child("UserActivities").child(activity.userID).child(activity.activityID)
        
        let activityData: [String: Any] = [
            "activityID": activity.activityID,
            "userID": activity.userID,
            "activityTimestamp": activity.activityTimestamp,
            "activityType": activity.activityType.rawValue,
            "albumID": activity.albumID,
            "albumReviewID": activity.albumReviewID ?? ""
        ]
        
        activityLogRef.setValue(activityData) { error, _ in
            if let error = error {
                completion(error)
                return
            }
            
            userActivityRef.setValue(activityData) { error, _ in
                if let error = error {
                    completion(error)
                    return
                }
                completion(nil)
            }
        }
        
    }
    
    func fetchUserActivities(userID: String, completion: @escaping ([Activity]?, Error?) -> Void) {
        let userActivitiesRef = databaseRef.child("UserActivities").child(userID)
        
        userActivitiesRef.queryOrdered(byChild: "activityTimestamp").observeSingleEvent(of: .value) { snapshot in
            var activities: [Activity] = []
            
            guard snapshot.exists() else {
                completion([], nil)
                return
            }
            
            for child in snapshot.children {
                if let activitySnapshot = child as? DataSnapshot,
                   let activityData = activitySnapshot.value as? [String: Any],
                   let activityID = activityData["activityID"] as? String,
                   let userID = activityData["userID"] as? String,
                   let activityTimestamp = activityData["activityTimestamp"] as? String,
                   let activityTypeRawValue = activityData["activityType"] as? String,
                   let activityType = ActivityType(rawValue: activityTypeRawValue),
                   let albumID = activityData["albumID"] as? String {
                    
                    let albumReviewID = activityData["albumReviewID"] as? String
                    
                    let activity = Activity(
                        activityID: activityID,
                        userID: userID,
                        activityTimestamp: activityTimestamp,
                        activityType: activityType,
                        albumID: albumID,
                        albumReviewID: albumReviewID
                    )
                    activities.append(activity)
                }
            }
            
            completion(activities, nil)
        } withCancel: { error in
            completion(nil, error)
        }
    }
    
    func checkActivityExists(userID: String, albumReviewID: String, completion: @escaping (String) -> Void) {
        let activityLogRef = databaseRef.child("ActivityLog")
        
        activityLogRef.observeSingleEvent(of: .value) { snapshot in
            var activityID = ""
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                if let activityData = child.value as? [String: Any],
                   let activityUserID = activityData["userID"] as? String,
                   let activityReviewID = activityData["albumReviewID"] as? String,
                   activityUserID == userID && activityReviewID == albumReviewID {
                    activityID = child.key
                    break
                }
            }
            completion(activityID)
        }
    }
    
    func updateExistingUsers() {
        databaseRef.child("Users").observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let userDict = snapshot.value as? [String: Any],
                   let username = userDict["username"] as? String {
                    let userID = snapshot.key
                    let normalizedUsername = FixStrings().normalizeString(username)
                    let bio = userDict["userBio"] as? String ?? ""
                    
                    Database.database().reference().child("Users").child(userID).updateChildValues([
                        "normalizedUsername": normalizedUsername,
                        "userBio": bio
                    ])
                }
            }
        }
    }
}

extension User {
    init?(snapshot: DataSnapshot) {
        guard let value = snapshot.value as? [String: Any] else {
            return nil
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: value)
            let user = try JSONDecoder().decode(User.self, from: jsonData)
            self = user
        } catch {
            return nil
        }
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "userID": userID,
            "username": username,
            "normalizedUsername": normalizedUsername,
            "email": email,
            "userProfilePictureURL": userProfilePictureURL,
            "userBio": userBio,
            "userAlbumFavorites": userAlbumFavorites ?? []
        ]
    }
}

extension UserConnections {
    init?(snapshot: DataSnapshot) {
        guard let value = snapshot.value as? [String: Any] else {
            return nil
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: value)
            let userConnections = try JSONDecoder().decode(UserConnections.self, from: jsonData)
            self = userConnections
        } catch {
            return nil
        }
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "userID": userID,
            "following": following ?? [],
            "followers": followers ?? []
        ]
    }
}

extension UserReviews {
    init?(snapshot: DataSnapshot) {
        guard let value = snapshot.value as? [String: Any] else {
            return nil
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: value)
            let userReviews = try JSONDecoder().decode(UserReviews.self, from: jsonData)
            self = userReviews
        } catch {
            return nil
        }
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "userID": userID,
            "userAlbumReviews": userAlbumReviews ?? []
        ]
    }
}

extension UserListenList {
    init?(snapshot: DataSnapshot) {
        guard let value = snapshot.value as? [String: Any] else {
            return nil
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: value)
            let userListenList = try JSONDecoder().decode(UserListenList.self, from: jsonData)
            self = userListenList
        } catch {
            return nil
        }
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "userID": userID,
            "userListenList": userListenList ?? []
        ]
    }
}
