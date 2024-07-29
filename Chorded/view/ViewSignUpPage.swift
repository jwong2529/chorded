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
    
    @EnvironmentObject var session: SessionStore
    @State private var email: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var error: String?
    
    var body: some View {
        ZStack {
            AppBackground()
            VStack {
                Image("vinyl").resizable().aspectRatio(contentMode: .fit).frame(minWidth: 300, minHeight: 400, alignment: .top)
                Text("Sign Up").font(.largeTitle).fontWeight(.bold)
                TextField("Username", text: $username).padding().frame(width: 300, height: 50).background(Color.black.opacity(0.05)).cornerRadius(10).autocapitalization(.none)
                TextField("Email", text: $email).padding().frame(width: 300, height: 50).background(Color.black.opacity(0.05)).cornerRadius(10).autocapitalization(.none)
                SecureField("Password", text: $password).padding().frame(width: 300, height: 50).background(Color.black.opacity(0.05)).cornerRadius(10).autocapitalization(.none)
                
                if let error = error {
                    Text(error).foregroundColor(.red)
                }
                
    //            Button("Sign Up") {
    //                // Authenification
    //            }.foregroundColor(.black).frame(width:300, height:50).background(Color.white).cornerRadius(50)
                
                Button(action: signUp) {
                    Text("Sign Up")
                        .foregroundColor(.black)
                        .frame(width: 300, height: 50)
                        .background(Color.white)
                        .cornerRadius(50)
                }

            }
        }
    }
    
    func signUp() {
        session.signUp(email: email, password: password, username: username) { error in
            if let error = error {
                self.error = error.localizedDescription
            } else {
                self.error = nil
            }
        }
    }
}

//#Preview {
//    ViewSignUpPage()
//}

