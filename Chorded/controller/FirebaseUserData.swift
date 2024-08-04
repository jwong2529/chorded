import Foundation
import FirebaseDatabase

class FirebaseUserData {
//    static let shared = FirebaseUserData()
//    
//    private init() {}
    
    func fetchUserData(uid: String, completion: @escaping (User?, Error?) -> Void) {
        let userRef = Database.database().reference().child("Users").child(uid)
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
    
    func fetchUserConnections(uid: String, completion: @escaping (UserConnections?, Error?) -> Void) {
        let connectionsRef = Database.database().reference().child("UserConnections").child(uid)
        connectionsRef.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists(), let connectionsData = snapshot.value as? [String: Any] else {
                completion(nil, NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "User connections not found in Firebase"]))
                return
            }
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: connectionsData, options: [])
                let connections = try JSONDecoder().decode(UserConnections.self, from: jsonData)
                completion(connections, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
    
    func fetchUserReviews(uid: String, completion: @escaping (UserReviews?, Error?) -> Void) {
        let reviewsRef = Database.database().reference().child("UserReviews").child(uid)
        reviewsRef.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists(), let reviewsData = snapshot.value as? [String: Any] else {
                completion(nil, NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "User reviews not found in Firebase"]))
                return
            }
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: reviewsData, options: [])
                let reviews = try JSONDecoder().decode(UserReviews.self, from: jsonData)
                completion(reviews, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
    
    func fetchUserListenList(uid: String, completion: @escaping (UserListenList?, Error?) -> Void) {
        let listenListRef = Database.database().reference().child("UserListenList").child(uid)
        listenListRef.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists(), let listenListData = snapshot.value as? [String: Any] else {
                completion(nil, NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "User listen list not found in Firebase"]))
                return
            }
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: listenListData, options: [])
                let listenList = try JSONDecoder().decode(UserListenList.self, from: jsonData)
                completion(listenList, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
    
    func logActivity(activity: Activity, completion: @escaping (Error?) -> Void) {
        let activityLogRef = Database.database().reference().child("ActivityLog").child(activity.activityID)
        let userActivityRef = Database.database().reference().child("UserActivities").child(activity.userID).child(activity.activityID)
        
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
        let userActivitiesRef = Database.database().reference().child("UserActivities").child(userID)
        
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
            "email": email,
            "userProfilePictureURL": userProfilePictureURL,
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
