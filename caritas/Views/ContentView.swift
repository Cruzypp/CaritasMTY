//
//  ContentView.swift
//  caritas
//
//  Created by Cruz Yael Pérez González on 30/10/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var auth: AuthViewModel

    @State private var email = ""
    @State private var password = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                // Logo
                Image(.logotipo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90, height: 90)
                    .frame(maxWidth: .infinity)

                // Title
                Text("Iniciar Sesión")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color("azulMarino"))

                // Campos
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("EMAIL")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                        TextField("hello@reallygreatsite.com", text: $email)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .keyboardType(.emailAddress)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("PASSWORD")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                        SecureField("••••••••", text: $password)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 32)

                // Botón Login
                Button {
                    Task { await auth.signIn(email: email, password: password) }
                } label: {
                    Text("Iniciar Sesión")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("azulMarino"))
                        .cornerRadius(10)
                }
                .shadow(color: Color.black.opacity(0.2), radius: 2, y: 2)
                .padding(.horizontal, 32)

                // Link a Sign Up
                HStack(spacing: 6) {
                    Text("¿No tienes cuenta?")
                        .foregroundColor(.secondary)
                    NavigationLink("Crea una") {
                        SignUpView()
                    }
                    .foregroundColor(Color("aqua"))
                    .fontWeight(.semibold)
                }

                // Error
                if let e = auth.error {
                    Text(e)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.horizontal, 32)
                        .multilineTextAlignment(.center)
                }

                Spacer()
            }
            .background(Color.white)
            .navigationBarBackButtonHidden(true)
            .ignoresSafeArea()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
