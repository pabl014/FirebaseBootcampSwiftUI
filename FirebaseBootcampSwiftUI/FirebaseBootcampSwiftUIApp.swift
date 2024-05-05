//
//  FirebaseBootcampSwiftUIApp.swift
//  FirebaseBootcampSwiftUI
//
//  Created by Paweł Rudnik on 05/05/2024.
//

import SwiftUI
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        //print("Configured Firebase!")
        return true
    }
}

@main
struct FirebaseBootcampSwiftUIApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                RootView()
            }
        }
    }
}
