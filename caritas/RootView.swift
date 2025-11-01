//
//  RootView.swift
//  caritas
//
//  Created by Juan Luis Alvarez Cisneros on 31/10/25.
//

import SwiftUI
import FirebaseAuth

struct RootView: View {
    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        if auth.user == nil {
            ContentView()
        } else {
            LoggedInView()        // temporal; luego pondremos MainTabView()
        }
    }
}

private struct LoggedInView: View {
    @EnvironmentObject var auth: AuthViewModel
    var body: some View {
        VStack(spacing: 16) {
            Text("¡Sesión iniciada!").font(.title3).bold()
            Text(auth.user?.email ?? "Usuario")
            Button("Cerrar sesión") { auth.signOut() }
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

