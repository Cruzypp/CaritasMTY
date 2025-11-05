//
//  SignUpView.swift
//  caritas
//
//  Created by Juan Luis Alvarez Cisneros on 31/10/25.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var mostrarPoliticas = false

    @State private var email = ""
    @State private var password = ""
    @State private var acceptPolicies = false

    private var canRegister: Bool { !email.isEmpty && !password.isEmpty && acceptPolicies }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Logo
            Image(.logotipo)
                .resizable()
                .scaledToFit()
                .frame(width: 90, height: 90)
                .frame(maxWidth: .infinity)

            // Title
            Text("Crear cuenta")
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
                        .font(.gotham(.regular, style: .body))
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
                        .font(.gotham(.regular, style: .body))
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 32)

            // Aceptación de políticas
            HStack {
                Button(action: {
                    withAnimation(.spring(duration: 0.18)) { acceptPolicies.toggle() }
                }) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(acceptPolicies ? Color("azulMarino") : .clear)
                        .frame(width: 26, height: 26)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color("azulMarino"), lineWidth: 2)
                        )
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(acceptPolicies ? .white : .clear)
                        )
                        .contentShape(Rectangle()) // hace tap fácil
                }
                .accessibilityLabel("Aceptar políticas de privacidad")
                .accessibilityValue(acceptPolicies ? "Activado" : "Desactivado")
                Text("Acepto el")
                    .font(.gotham(.regular, style: .callout))
                    .foregroundColor(.gray)

                Button {
                    mostrarPoliticas.toggle()
                } label: {
                    Text("Aviso de Privacidad")
                        .font(.gotham(.bold, style: .callout))
                        .foregroundColor(Color("aqua"))
                        .underline()
                }
                .sheet(isPresented: $mostrarPoliticas) {
                    PrivacyNoticeView()
                }
            }
            .padding(.horizontal, 32)

            // Botón Registro
            Button {
                Task { await auth.signUp(email: email, password: password, acceptedPolicies: acceptPolicies) }
            } label: {
                Text("Registrarme")
                    .font(.gotham(.bold, style: .headline))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canRegister ? Color("aqua") : Color.gray.opacity(0.4))
                    .cornerRadius(10)
            }
            .disabled(!canRegister)
            .shadow(color: Color.black.opacity(0.15), radius: 2, y: 2)
            .padding(.horizontal, 32)

            // Link a Login
            HStack(spacing: 6) {
                Text("¿Ya tienes cuenta?")
                    .font(.gotham(.regular, style: .body))
                    .foregroundColor(.secondary)
                // Usamos dismiss para volver, pero también sirve como link explícito
                NavigationLink{
                    ContentView()
                } label: {
                    Text("Inicia sesión")
                        .font(.gotham(.bold, style: .body))
                }
                .foregroundColor(Color("azulMarino"))
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

#Preview {
    SignUpView()
        .environmentObject(AuthViewModel())
}
