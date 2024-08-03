import Foundation
import FirebaseDatabase

class FirebaseUserData {
    static let shared = FirebaseUserData()
    
    private init() {}
    
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
    
    func logActivity(activity: Activity) {
        let activityLogRef = Database.database().reference().child("ActivityLog")
        let userActivityRef = Database.database().reference().child("UserActivities")
        
        let activityData: [String: Any] = [
            "id": activity.id,
            "userID": activity.userID,
            "timestamp": activity.timestamp,
            "type": activity.type
        ]
        
        activityLogRef.child(activity.id).setValue(activityData)
        userActivityRef.child(activity.userID).child(activity.id).setValue(activityData)
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
            "id": id,
            "username": username,
            "email": email,
            "profilePictureURL": profilePictureURL,
            "albumFavorites": albumFavorites ?? []
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
            "id": id,
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
            "id": id,
            "albumReviews": albumReviews ?? []
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
            "id": id,
            "listenList": listenList ?? []
        ]
    }
}
