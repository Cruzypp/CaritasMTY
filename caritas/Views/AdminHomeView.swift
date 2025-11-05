//
//  AdminHomeView.swift
//  caritas
//
//  Created by Juan Luis Alvarez Cisneros on 05/11/25.
//

import SwiftUI

struct AdminHomeView: View {
    @EnvironmentObject var auth: AuthViewModel
    var body: some View {
        Button(role: .destructive) {
            auth.signOut()
        } label: {
            Label("Cerrar sesión", systemImage: "rectangle.portrait.and.arrow.right")
        }
        .accessibilityLabel("Cerrar sesión")
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        
    }
}

#Preview {
    AdminHomeView()
}
