import SwiftUI

struct ViewHomePage: View {
    
    @State private var searchText = ""
    
    init() {
//        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
//        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont(name: "Georgia-Bold", size: 26)!]
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                VStack {
                    NavigationLink(destination: TrendingAlbumsView()) {
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
                        HStack {
                            
                        }
                    }
                    .buttonStyle(HighlightButtonStyle())
                    Spacer()
                }
            }
            
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text("App Name").font(.system(size: 26, weight: .bold, design: .default))
                            .foregroundColor(.white)
                            
                    }
                }
            }
            .searchable(text: $searchText)
        }
    }
}

#Preview {
    ViewHomePage()
}
