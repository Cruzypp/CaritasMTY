//
//  ContentView.swift
//  caritas
//
//  Created by Cruz Yael Pérez González on 30/10/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var auth: AuthViewModel   // ← inyectado desde caritasApp

    @State private var email = ""
    @State private var password = ""
    @State private var acceptPolicies = false
    @State private var buttonAnimation = false

    private var canRegister: Bool { !email.isEmpty && !password.isEmpty && acceptPolicies }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Logo
            Image(.logotipo)
                .resizable()
                .scaledToFit()
                .frame(width: 90, height: 90)
                .foregroundColor(Color(.azulMarino))

            // Title
            Text("Iniciar Sesión")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(.azulMarino))

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

            // Accept policies
            HStack {
                Button(action: { acceptPolicies.toggle() }) {
                    Image(systemName: acceptPolicies ? "checkmark.square.fill" : "square")
                        .foregroundColor(acceptPolicies ? Color("PrimaryBlue") : .gray)
                        .font(.title3)
                }
                Text("ACEPTAR POLÍTICAS")
                    .font(.callout)
                    .foregroundColor(.gray)
            }

            // Buttons
            VStack(spacing: 14) {
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

                Button {
                    Task { await auth.signUp(email: email, password: password, acceptedPolicies: acceptPolicies) }
                } label: {
                    Text("Registrarse")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canRegister ? Color("aqua") : Color.gray.opacity(0.4))
                        .cornerRadius(10)
                }
                .disabled(!canRegister)
            }
            .padding(.horizontal, 32)

            if let e = auth.error {
                Text(e).foregroundColor(.red).font(.footnote).padding(.horizontal, 32)
            }

            Spacer()
        }
        .background(Color.white)
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())  // para que el preview compile
}
