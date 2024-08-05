import SwiftUI

struct ViewHomePage: View {
    
    @State private var searchText = ""
    @State private var trendingAlbums = [Album]()
    @State private var topAlbumsLast25Yrs = [Album]()
    @State private var greatestAlbumsOfAllTime = [Album]()
    
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
                        .padding(.bottom)
                    
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
                    
                    
                    NavigationLink(destination: ViewActivitiesPage()) {
                        HStack {
                            Text("Recent from friends")
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
                    
                    //                    AlbumCarousel(albumImages: Array(repeating: "sampleAlbumCover", count: 10), count: 10)
                    //
                    Spacer()
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
                fetchAlbums()
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
    
    
    func fetchAlbums() {
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
}

//#Preview {
//    ViewHomePage()
//}


