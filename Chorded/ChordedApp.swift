//
//  MusicReviewAppApp.swift
//  MusicReviewApp
//
//  Created by Janice Wong on 5/23/24.
//

import SwiftUI
import FirebaseCore

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
//            ViewHomePage()
//            BottomTabView()
            ContentView().environmentObject(session)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var session: SessionStore
    
    var body: some View {
        Group {
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
