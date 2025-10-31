//
//  ContentView.swift
//  caritas
//
//  Created by Cruz Yael Pérez González on 30/10/25.
//

import SwiftUI

struct ContentView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var acceptPolicies = false
    @State private var buttonAnimation = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Logo
            Image(.logotipo)
                .resizable()
                .scaledToFit()
                .frame(width: 90, height: 90)
                .foregroundColor(Color("PrimaryBlue"))
            
            // Title
            Text("Iniciar Sesión")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundColor(Color("azulMarino"))
            
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
                        .autocapitalization(.none)
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
                }
                Text("ACEPTAR POLÍTICAS")
                    .font(.callout)
                    .foregroundColor(.gray)
            }
            
            // Buttons
            VStack(spacing: 14) {
                Button{
                    
                } label: {
                    Text("Iniciar Sesión")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("azulMarino"))
                        .cornerRadius(10)
                }
                .shadow(color: Color.black, radius: 1, x: 0.0, y: 2.0)
                
                Button {
                    // Acción Log In
                } label: {
                    Text("Registrarse")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("aqua"))
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 32)
            
            Spacer()
        }
        .background(Color.white)
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
