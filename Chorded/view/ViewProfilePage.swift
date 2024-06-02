//
//  ViewProfile.swift
//  MusicReviewApp
//
//  Created by Janice Wong on 5/25/24.
//

import Foundation
import SwiftUI

struct ViewProfilePage: View {
    init() {
//        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                NavigationView{
                    
                    ScrollView{
                        
                        VStack{
                            Image("profilePic").resizable().aspectRatio(contentMode: .fit).frame(width: 120, height: 120).cornerRadius(100).padding(22).padding(.top,-20)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        VStack{
                            Text("Spongebob").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/).fontWeight(.bold).offset(x:120, y:-20)
                            Text("300").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/).fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).offset(x:-10, y:5)
                            Text("Following").font(.system(size:15)).fontWeight(.light).offset(x:-10, y:5)
                            Text("100").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/).fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).offset(x:130, y:-47)
                            Text("Followers").font(.system(size:15)).fontWeight(.light).offset(x:130, y:-45)
                            Text("5").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/).fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).offset(x:260, y:-98)
                            Text("Reviews").font(.system(size:15)).fontWeight(.light).offset(x:260, y:-95)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        
                        VStack{
                            
                        
                            HStack {
                                Text("Recent Activity")
                                    .font(.system(size: 20, weight: .medium, design: .default))
                                    .foregroundColor(.black)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.blue)
                            }
                            .contentShape(Rectangle())
                            .padding()
                        }
                        .buttonStyle(HighlightButtonStyle())
                        
//                        AlbumCarousel(albumImages: Array(repeating: "sampleAlbumCover", count: 10), count: 10)
                        
                        Spacer()
                        
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ViewProfilePage()
}
