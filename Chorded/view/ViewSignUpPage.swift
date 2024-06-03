//
//  ViewSignUpPage.swift
//  Chorded
//
//  Created by Tiffany Mo on 6/2/24.
//

import Foundation
import SwiftUI



struct ViewSignUpPage: View {
    init() {
        //        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    @State private var username = ""
    @State private var password = ""
    
    var body: some View {
        VStack {
            Color.black
            Image("Logo").resizable().aspectRatio(contentMode: .fit).frame(minWidth: 300, minHeight: 400, alignment: .top)
            Text("Sign Up").font(.largeTitle).fontWeight(.bold)
            TextField("Name", text: $username).padding().frame(width: 300, height: 50).background(Color.black.opacity(0.05)).cornerRadius(10)
            TextField("Email", text: $username).padding().frame(width: 300, height: 50).background(Color.black.opacity(0.05)).cornerRadius(10)
            SecureField("Password", text: $password).padding().frame(width: 300, height: 50).background(Color.black.opacity(0.05)).cornerRadius(10)
            
            Button("Sign Up") {
                // Authenification
            }.foregroundColor(.black).frame(width:300, height:50).background(Color.white).cornerRadius(50)

        }
    }
}

#Preview {
    ViewSignUpPage()
}

