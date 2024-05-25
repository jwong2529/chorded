import SwiftUI

struct ContentView: View {
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.blue, .black]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    
                    HStack {
                        Text("Trending")
                            .font(.system(size: 20, weight: .medium, design: .default))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.white)
                            .padding(.leading, 30)
                    }
                
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Spacer().frame(height: 20)
                        Text("App Name")
                            .font(.largeTitle.bold())
                            .accessibilityAddTraits(.isHeader)
                            .foregroundColor(.white)
                        Spacer().frame(height: 20)
                    }
                }
            }

            .searchable(text: $searchText)
        }
    }
}

#Preview {
    ContentView()
}
