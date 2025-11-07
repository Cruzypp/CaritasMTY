//
//  caritasApp.swift
//  caritas
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

// MARK: - AppDelegate (solo para Firebase.configure())
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct caritasApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var auth = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(auth)
                .environment(\.font, .gotham(.regular, style: .body))
                // Manejo del callback de Google
                .onOpenURL { url in
                    _ = GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
