//
//  ViewLogInPage.swift
//  Chorded
//
//  Created by Tiffany Mo on 6/2/24.
//

import Foundation
import SwiftUI

struct ViewLogInPage: View {
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
            Text("Log In").font(.largeTitle).fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
            TextField("Username", text: $username).padding().frame(width: 300, height: 50).background(Color.black.opacity(0.05)).cornerRadius(10)
            SecureField("Password", text: $password).padding().frame(width: 300, height: 50).background(Color.black.opacity(0.05)).cornerRadius(10)
            
            Button("Login") {
                // Authenification
            }.foregroundColor(.black).frame(width:300, height:50).background(Color.white).cornerRadius(50)
            Text("Don't have an account yet?").padding()
            Button("Sign Up") {
                
            }
        }

        
    }
}


#Preview {
    ViewLogInPage()
}
