//
//  ViewSignUpPage.swift
//  Chorded
//
//  Created by Tiffany Mo on 6/2/24.
//

import Foundation
import SwiftUI



struct ViewSignUpPage: View {
    
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
            ScrollView {
                VStack {
                    Image("vinyl")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(minWidth: 300, minHeight: 400, alignment: .top)
                    
                    Text("Sign Up")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    TextField("Username", text: $username)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)
                        .autocapitalization(.none)
                    
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
                    
                    Button(action: signUp) {
                        Text("Sign Up")
                            .foregroundColor(.black)
                            .frame(width: 300, height: 50)
                            .background(Color.white)
                            .cornerRadius(50)
                            .padding(.bottom)
                    }
                    
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(""), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func signUp() {
        guard validateUsername(username) else {
            alertMessage = "Username must be one word, between 3 and 30 characters, and not contain .$#[]/"
            showAlert = true
            return
        }
        guard validateEmail(email) else {
            alertMessage = "Please enter a valid email address"
            showAlert = true
            return
        }
        
        guard validatePassword(password) else {
            alertMessage = "Password must be at least 6 characters and no more than 30 characters"
            showAlert = true
            return
        }
        
        let normalizedUsername = FixStrings().normalizeString(username)
        session.signUp(email: email, password: password, username: username, normalizedUsername: normalizedUsername) { error in
            if let error = error {
                print("Error signing up user: \(error.localizedDescription)")
            } else {
                showAlert = false
            }
        }
    }
    
    func validateUsername(_ username: String) -> Bool {
        let invalidCharacters = CharacterSet(charactersIn: ".$#[]/")
        if username.rangeOfCharacter(from: invalidCharacters) != nil {
            return false
        } else {
            return username.count >= 3 && username.count <= 30
        }
    }
    
    func validateEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
    
    func validatePassword(_ password: String) -> Bool {
        return password.count >= 6 && password.count <= 30
    }
}

//#Preview {
//    ViewSignUpPage()
//}

