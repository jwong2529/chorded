import SwiftUI
import SDWebImageSwiftUI

struct ViewHomePage: View {
    @EnvironmentObject var session: SessionStore
    
    @State private var searchText = ""
    @State private var trendingAlbums = [Album]()
    @State private var topAlbumsLast25Yrs = [Album]()
    @State private var greatestAlbumsOfAllTime = [Album]()
    
    @State private var recentActivities: [Activity] = []
    
    @StateObject private var quickTesting = QuickTesting()
    
    @State private var currentIndex = 0
    private let timer = Timer.publish(every: 6, on: .main, in: .common).autoconnect()
    let albumList: [(title: String, gradientColors: [Color], design: String)] = [
        ("Top Albums of the Last 25 Years", [Color.green, Color.teal], "fanned"),
        ("Greatest Albums Of All Time", [Color.red, Color.brown], "vinyl")
    ]
    
    init() {
//        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
//        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont(name: "Georgia-Bold", size: 26)!]
        
//        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = .systemGray4
//        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = .black
//        UISearchBar.appearance().barTintColor = UIColor.white
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                ScrollView {
                    VStack {
                        NavigationLink(destination: ViewTrendingAlbumsPage(trendingAlbums: trendingAlbums)) {
                            HStack {
                                Text("Trending")
                                    .font(.system(size: 20, weight: .medium, design: .default))
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.blue)
                            }
                            .contentShape(Rectangle())
                            .padding()
                        }
                        .buttonStyle(HighlightButtonStyle())
                        
                        AlbumCarousel(albums: trendingAlbums, albumCount: 10)
                            .padding(.bottom, 5)
                        
                        TabView(selection: $currentIndex) {
                            ForEach(0..<albumList.count) { index in
                                let albumsToPass = determineAlbumsToPass(index: index)
                                NavigationLink(destination: ViewCustomListPage(albums: albumsToPass, listName: albumList[index].title)) {
                                    AlbumListCard(title: albumList[index].title, gradientColors: albumList[index].gradientColors, design: albumList[index].design, albums: albumsToPass)
                                    
                                }
                                .buttonStyle(HighlightButtonStyle())
                                .tag(index)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle())
                        .frame(height: 220)
                        .onReceive(timer) { _ in
                            withAnimation(.spring) {
                                currentIndex = (currentIndex + 1) % albumList.count
                            }
                        }
                        
                        HomePageRecentActivityView(activities: recentActivities)
                            .padding(.top, 5)
                            .padding(.bottom)
                        
                        Spacer()
                    }
                }
            }
            
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text("Chorded").font(.system(size: 26, weight: .bold, design: .default))
                            .foregroundColor(.white)
                        
                    }
                }
            }
//            .searchable(text: $searchText)
            .onAppear {
                fetchData()
            }
        }
    
    }
    
    func determineAlbumsToPass(index: Int) -> [Album] {
        switch index {
        case 0:
            return topAlbumsLast25Yrs
        case 1:
            return greatestAlbumsOfAllTime
        default:
            return []
        }
    }
    
    private func fetchData() {
        fetchAlbums()
        fetchConnectionsRecentActivities()
    }
    
    
    private func fetchAlbums() {
        FirebaseDataManager().fetchAlbumListAndDetails(listName: "TrendingAlbums") { albums, error in
            if let error = error {
                print("Failed to fetch trending albums: \(error.localizedDescription)")
            } else if let albums = albums {
                self.trendingAlbums = albums
                print("Fetched trending albums")
            }
        }
        
        FirebaseDataManager().fetchAlbumListAndDetails(listName: "TopAlbumsLast25Yrs") { albums, error in
            if let error = error {
                print("Failed to fetch TopAlbumsLast25Yrs: \(error.localizedDescription)")
            } else if let albums = albums {
                self.topAlbumsLast25Yrs = albums
                print("Fetched TopAlbumsLast25Yrs")
            }
        }
        
        FirebaseDataManager().fetchAlbumListAndDetails(listName: "GreatestAlbumsOfAllTimeRS") { albums, error in
            if let error = error {
                print("Failed to fetch GreatestAlbumsOfAllTimeRS: \(error.localizedDescription)")
            } else if let albums = albums {
                self.greatestAlbumsOfAllTime = albums
                print("Fetched GreatestAlbumsOfAllTimeRS")
            }
        }
        
    }
    
    private func fetchConnectionsRecentActivities() {
        guard let userID = session.currentUserID else {
            print("No current user ID found")
            return
        }

        // Fetch the following list
        FirebaseUserData().fetchFollowing(uid: userID) { followingList in

            var allActivities: [Activity] = []
            let dispatchGroup = DispatchGroup()
            
            // Calculate the date for ten weeks ago
            let tenWeeksAgo = Calendar.current.date(byAdding: .weekOfYear, value: -10, to: Date())

            for user in followingList {
                dispatchGroup.enter()
                FirebaseUserData().fetchUserActivities(userID: user) { fetchedUserActivities, error in
                    if let error = error {
                        print("Failed to fetch activities for user \(user): \(error.localizedDescription)")
                    } else if let fetchedUserActivities = fetchedUserActivities {
                        // Filter activities to include only those from the last ten weeks
                        let recentActivities = fetchedUserActivities.filter { activity in
                            if let activityDate = ISO8601DateFormatter().date(from: activity.activityTimestamp) {
                                return activityDate >= tenWeeksAgo! && activity.activityType == .albumReview
                            }
                            return false
                        }
                        allActivities.append(contentsOf: recentActivities)
                    }
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) {
                // Sort all activities by activityTimestamp
                allActivities.sort { activity1, activity2 in
                    guard let timestamp1 = ISO8601DateFormatter().date(from: activity1.activityTimestamp),
                          let timestamp2 = ISO8601DateFormatter().date(from: activity2.activityTimestamp) else {
                        return false
                    }
                    return timestamp1 > timestamp2
                }
                // Assign the sorted activities to self.activities
                self.recentActivities = allActivities
            }
        }
    }
}

//#Preview {
//    ViewHomePage()
//}


struct HomePageRecentActivityView: View {
    var activities: [Activity]
    
    var body: some View {
        VStack(alignment: .leading) {
            NavigationLink(destination: ViewRecentFriendsActivityFromHomePage(activities: activities)) {
                HStack {
                    Text("Recent from friends")
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

            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack(spacing: 15) {
                    ForEach(activities.prefix(3), id: \.activityID) { activity in
                        HomePageRecentActivityAlbumsView(activity: activity)
                    }
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
    }
}

struct HomePageRecentActivityAlbumsView: View {
    var activity: Activity
    @State private var albumReview: AlbumReview = AlbumReview(albumReviewID: "", userID: "", albumKey: "", rating: 0.0, reviewText: "", reviewTimestamp: "")
    @State private var user: User = User(userID: "", username: "", normalizedUsername: "", email: "", userProfilePictureURL: "", userBio: "")
    @State private var album: Album = Album(title: "", artistID: [], artistNames: [], genres: [], styles: [], year: 0, albumTracks: [], coverImageURL: "")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            NavigationLink(destination: ViewSpecificReviewPage(review: albumReview, user: user, album: album)) {
                if album.coverImageURL != "", let url = URL(string: album.coverImageURL) {
                    WebImage(url: url)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 150, height: 150)
                        .clipped()
                        .cornerRadius(10)
                        .shadow(radius: 5)
                } else {
                    PlaceholderAlbumCover(width: 150, height: 150)
                }
            }
            HStack(spacing: 5) {
                NavigationLink(destination: ViewProfilePage(userID: user.userID)) {
                    if let url = URL(string: user.userProfilePictureURL) {
                        WebImage(url: url)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 25, height: 25)
                            .clipShape(Circle())
                    } else {
                        PlaceholderUserImage(width: 25, height: 25)
                    }
                }
                VStack(alignment: .leading, spacing: 5) {
                    Text("\(user.username)")
                        .font(.body)
                        .foregroundColor(.gray)
                    StarRatingView(rating: albumReview.rating, starSize: 10)
                        .padding(.top, -5)
                }
                .frame(maxWidth: 110, alignment: .leading)
            }
        }
        .onAppear() {
            //fetch album review, user, album
            fetchData()
        }
    }
    
    private func fetchData() {
        fetchUser(userID: activity.userID)
        fetchAlbum(albumID: activity.albumID)
        fetchAlbumReview(reviewID: activity.albumReviewID ?? "", albumKey: activity.albumID)
    }
    
    private func fetchUser(userID: String) {
        FirebaseUserData().fetchUserData(uid: userID) { fetchedUser, error in
            if let error = error {
                print("Failed to fetch user data: \(error.localizedDescription)")
            } else if let fetchedUser = fetchedUser {
                self.user = fetchedUser
            }
        }
    }
    
    private func fetchAlbum(albumID: String) {
        FirebaseDataManager().fetchAlbum(firebaseKey: albumID) { fetchedAlbum, error in
            if let error = error {
                print("Error fetching album: ", error)
            } else if let fetchedAlbum = fetchedAlbum {
                self.album = fetchedAlbum
            }
        }
    }
    
    private func fetchAlbumReview(reviewID: String, albumKey: String) {
        FirebaseDataManager().fetchSpecificAlbumReview(albumKey: albumKey, reviewID: reviewID) { fetchedReview, error in
            if let error = error {
                print("Failed to fetch album review: \(error.localizedDescription)")
            } else if let fetchedReview = fetchedReview {
                self.albumReview = fetchedReview
            }
        }
    }
    
}
