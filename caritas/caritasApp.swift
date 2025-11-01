//
//  caritasApp.swift
//  caritas
//
//  Created by Juan Luis Alvarez Cisneros on 31/10/25.
//

import SwiftUI
import Firebase
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()

        // ⚠️ Temporal para desarrollo: se eliminará cuando el login real quede listo
        //Auth.auth().signInAnonymously { result, error in
         //   if let error = error {
           //     print("❌ Anon sign-in error:", error.localizedDescription)
           // } else {
           //     print("✅ Signed in anonymously. UID:", result?.user.uid ?? "nil")
        //   }
      //  }
        return true
    }
}

@main
struct caritasApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var auth = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(auth)
        }
    }
}
