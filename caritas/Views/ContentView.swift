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
                    .font(.gotham(.bold, style: .largeTitle))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color("azulMarino"))

                // Campos
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("EMAIL")
                            .font(.gotham(.bold, style: .caption))
                            .foregroundColor(.gray)
                        TextField("hello@reallygreatsite.com", text: $email)
                            .font(.gotham(.regular, style: .headline))
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .keyboardType(.emailAddress)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("PASSWORD")
                            .font(.gotham(.bold, style: .caption))
                            .foregroundColor(.gray)
                        SecureField("••••••••", text: $password)
                            .font(.gotham(.regular, style: .headline))
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
                        .font(.gotham(.bold, style: .headline))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("azulMarino"))
                        .cornerRadius(10)
                }
                .shadow(color: Color.black.opacity(0.2), radius: 2, y: 2)
                .padding(.horizontal, 32)
                // Botón Google
                Button {
                    Task { await auth.signInWithGoogle() }
                } label: {
                    HStack {
                        Image("google_icon")
                            .resizable()
                            .frame(width: 18, height: 18)

                        Text("Continuar con Google")
                            .font(.gotham(.bold, style: .headline))
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .cornerRadius(10)
                }
                .shadow(color: Color.black.opacity(0.05), radius: 2, y: 2)
                .padding(.horizontal, 32)
                // Link a Sign Up
                HStack(spacing: 6) {
                    Text("¿No tienes cuenta?")
                        .foregroundColor(.secondary)
                        .font(.gotham(.regular, style: .body))
                    NavigationLink("Crea una") {
                        SignUpView()
                    }
                    .foregroundColor(Color(.azulMarino))
                    .font(.gotham(.bold, style: .body))
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
