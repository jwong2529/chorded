//
//  MusicReviewAppApp.swift
//  MusicReviewApp
//
//  Created by Janice Wong on 5/23/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct ChordedApp: App {
    
    //register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var session = SessionStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(session)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var session: SessionStore
    
    var body: some View {
        Group {
            if session.isCheckingLogin {
                // Show the launch screen or splash screen while checking
                SplashScreenView()
            } else {
                if session.isLoggedIn {
                    BottomTabView()
                } else {
                    NavigationView {
                        ViewLogInPage()
                    }
                }
            }
        }
    }
}

struct SplashScreenView: View {
    var body: some View {
        VStack {
            Spacer()
            
            ProgressView() // Loading spinner
                .scaleEffect(1.5) // Adjust the size of the spinner
                .progressViewStyle(CircularProgressViewStyle())
                .padding(.bottom, 20) // Adjust the spacing if needed
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.blue.opacity(0.2))
        .edgesIgnoringSafeArea(.all)
    }
}
