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
    @State private var showSuccessMessage = false

    @State private var email = ""
    @State private var password = ""
    @State private var acceptPolicies = true

    @FocusState private var focusedField: Field?
    enum Field {
        case email
        case password
    }

    private var canRegister: Bool { !email.isEmpty && !password.isEmpty }

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
                    TextField("correo", text: $email)
                        .font(.gotham(.regular, style: .body))
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.emailAddress)
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .password }
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
                        .focused($focusedField, equals: .password)
                        .submitLabel(.done)
                        .onSubmit { focusedField = nil }
                }
            }
            .padding(.horizontal, 32)
            .onTapGesture {
                // No hace nada aquí, el tap es para mantener el focus en los campos
            }

            // Aceptación de políticas
            VStack {
                Button(action: {
                    withAnimation(.spring(duration: 0.18)) { acceptPolicies.toggle() }
                }) {
                    /*
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
                     */
                }
                .accessibilityLabel("Aceptar políticas de privacidad")
                .accessibilityValue(acceptPolicies ? "Activado" : "Desactivado")
                
                Text("Al crear una cuenta aceptas el")
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
                Task {
                    await auth.signUp(email: email, password: password, acceptedPolicies: acceptPolicies)
                    if auth.error == nil && auth.user != nil {
                        showSuccessMessage = true
                        // Navega automáticamente después de 1.5 segundos
                        try? await Task.sleep(nanoseconds: 1_500_000_000)
                    }
                }
            } label: {
                if auth.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Registrarme")
                        .font(.gotham(.bold, style: .headline))
                }

            }
            .foregroundColor(.white)
            .disabled(!canRegister || auth.isLoading)
            .shadow(color: Color.black.opacity(0.15), radius: 2, y: 2)
            .frame(maxWidth: .infinity)
            .padding()
            .background(canRegister && !auth.isLoading ? Color("aqua") : Color.gray.opacity(0.4))
            .cornerRadius(10)
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

            // Error o Éxito
            if let e = auth.error {
                Text(e)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .padding(.horizontal, 32)
                    .multilineTextAlignment(.center)
            }
            
            if showSuccessMessage && auth.user != nil {
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title3)
                        Text("¡Cuenta creada exitosamente!")
                            .font(.gotham(.bold, style: .body))
                            .foregroundColor(.green)
                    }
                    Text("Redireccionando...")
                        .font(.gotham(.regular, style: .caption))
                        .foregroundColor(.green)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal, 32)
            }

            Spacer()
        }
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea()
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    SignUpView()
        .environmentObject(AuthViewModel())
}
