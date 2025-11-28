//
//  DonorSettingsView.swift
//  caritas
//
//  Created by ChatGPT on 17/11/25.
//

import SwiftUI
import FirebaseAuth

struct DonorSettingsView: View {
    @EnvironmentObject var auth: AuthViewModel
    
    private let azul = Color("azulMarino")
    
    private var gradientColors: Gradient {
        Gradient(colors: [.naranja, .aqua])
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Icono de usuario
                    VStack(spacing: 8) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(azul)
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(gradient: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing),
                                        lineWidth: 5
                                    )
                                    .shadow(color: .naranja, radius: 6, x: 0, y: 0)
                                    .frame(width: 90, height: 80)
                            )
                        
                        Text("Usuario Donante")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 32)
                    
                    
                    // Datos del usuario
                    VStack(alignment: .leading, spacing: 16) {
                        
                        Text("Cuenta")
                            .font(.gotham(.bold, style: .headline))
                        
                        // Email (solo lectura)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Email")
                                .font(.gotham(.bold, style: .caption))
                                .foregroundColor(.gray)
                            
                            Text(auth.user?.email ?? "usuario@correo.com")
                                .font(.gotham(.regular, style: .body))
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    
                    // Botón de logout
                    Button {
                        auth.signOut()
                    } label: {
                        Text("Cerrar sesión")
                            .font(.gotham(.bold, style: .body))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(azul)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.top, 320)
                    
                    Spacer(minLength: 20)
                }
            }
            .navigationTitle("Configuración")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


// MARK: Preview
struct DonorSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        let auth = AuthViewModel()
        auth.role = "donante"
        return DonorSettingsView()
            .environmentObject(auth)
    }
}
