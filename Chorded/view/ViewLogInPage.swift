//
//  ViewLogInPage.swift
//  Chorded
//
//  Created by Tiffany Mo on 6/2/24.
//

import Foundation
import SwiftUI

struct ViewLogInPage: View {
    
    @EnvironmentObject var session: SessionStore
    @State private var email: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
//    @State private var error: String?
    
    @State private var showPassword: Bool = false
    @FocusState var inFocus: Field?
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    enum Field {
        case secure, plain
    }
    
    init() {
        //        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    var body: some View {
        ZStack {
            AppBackground()
            VStack {
                Image("vinyl")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(minWidth: 300, minHeight: 400, alignment: .top)
                
                Text("Log In")
                    .font(.largeTitle)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                
                TextField("Email", text: $email)
                    .padding()
                    .frame(width: 300, height: 50)
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(10)
                    .autocapitalization(.none)
                
                ZStack(alignment: .trailing) {
                    GeometryReader { geometry in
                        if showPassword {
                            TextField("Password", text: $password)
                                .focused($inFocus, equals: .plain)
                                .padding()
                                .frame(width: 300, height: 50)
                                .background(Color.black.opacity(0.05))
                                .cornerRadius(10)
                                .autocapitalization(.none)
                        } else {
                            SecureField("Password", text: $password)
                                .focused($inFocus, equals: .secure)
                                .padding()
                                .frame(width: 300, height: 50)
                                .background(Color.black.opacity(0.05))
                                .cornerRadius(10)
                                .autocapitalization(.none)
                        }
                    }
                    .frame(width: 300, height: 50)
                    
                    Button(action: {
                        self.showPassword.toggle()
                        if showPassword {
                            inFocus = .plain
                        } else {
                            inFocus = .secure
                        }
                    }) {
                        Image(systemName: showPassword ? "eye.slash" : "eye.fill")
                            .padding()
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: 300, height: 50)
                
                Button(action: signIn) {
                    Text("Log In")
                        .foregroundColor(.black)
                        .frame(width: 300, height: 50)
                        .background(Color.white)
                        .cornerRadius(50)
                }
                
                Text("Don't have an account yet?").padding()

                NavigationLink("Sign Up", destination: ViewSignUpPage())
                    .foregroundColor(.blue)
                    .padding(.bottom)
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(""), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        
    }
    
    func signIn() {
        session.signIn(email: email, password: password) { error in
            if let error = error {
                alertMessage = "Incorrect credentials. Please try again."
                showAlert = true
            }
        }
    }
}


//#Preview {
//    ViewLogInPage()
//}
