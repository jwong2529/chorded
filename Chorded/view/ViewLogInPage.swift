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
                Text("Log In").font(.largeTitle).fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                TextField("Email", text: $email).padding().frame(width: 300, height: 50).background(Color.black.opacity(0.05)).cornerRadius(10).autocapitalization(.none)
                SecureField("Password", text: $password).padding().frame(width: 300, height: 50).background(Color.black.opacity(0.05)).cornerRadius(10).autocapitalization(.none)
                
                if let error = error {
                    Text("Incorrect credentials. Please try again.").foregroundColor(.red)
                }
                
    //            Button("Login") {
    //                // Authenification
    //            }.foregroundColor(.black).frame(width:300, height:50).background(Color.white).cornerRadius(50)
                
                Button(action: signIn) {
                    Text("Log In")
                        .foregroundColor(.black)
                        .frame(width: 300, height: 50)
                        .background(Color.white)
                        .cornerRadius(50)
                }
                
                Text("Don't have an account yet?").padding()
    //            Button("Sign Up") {
    //
    //            }
                NavigationLink("Sign Up", destination: ViewSignUpPage())
                    .foregroundColor(.blue)
            }
        }
        
    }
    
    func signIn() {
        session.signIn(email: email, password: password) { error in
            if let error = error {
                self.error = error.localizedDescription
            } else {
                self.error = nil
            }
        }
    }
}


//#Preview {
//    ViewLogInPage()
//}
