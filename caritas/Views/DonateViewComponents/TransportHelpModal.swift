//
//  TransportHelpModal.swift
//  caritas
//
//  Created by Cruz Yael Pérez González on 14/11/25.
//

import SwiftUI

struct TransportHelpModal: View {
    @Binding var isPresented: Bool
    let onConfirm: (Bool) -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            // MARK: - Header
            HStack {
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            
            Spacer()
            
            // MARK: - Icono
            Image(systemName: "truck.box.fill")
                .font(.system(size: 60))
                .foregroundColor(.naranja)
            
            // MARK: - Título
            VStack(spacing: 12) {
                Text("¿Necesitas ayuda con el traslado?")
                    .font(.gotham(.bold, style: .title))
                    .foregroundColor(.azulMarino)
                
                Text("Podemos ayudarte a transportar tu donación")
                    .font(.gotham(.regular, style: .body))
                    .foregroundColor(.secondary)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            
            // MARK: - Opciones
            VStack(spacing: 12) {
                // Opción SÍ
                Button(action: {
                    onConfirm(true)
                    isPresented = false
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.headline)
                        Text("Sí, necesito ayuda")
                            .font(.gotham(.bold, style: .headline))
                        Spacer()
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.aqua)
                    .cornerRadius(12)
                }
                
                // Opción NO
                Button(action: {
                    onConfirm(false)
                    isPresented = false
                }) {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .font(.headline)
                        Text("No, lo haré yo mismo")
                            .font(.gotham(.bold, style: .headline))
                        Spacer()
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.grisOscuro)
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal)
            
            // MARK: - Información de contacto
            VStack(spacing: 12) {
                Text("Si necesitas ayuda, comunícate al:")
                    .font(.gotham(.regular, style: .body))
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.naranja)
                    Text("2221903422")
                        .font(.gotham(.bold, style: .headline))
                        .foregroundColor(.azulMarino)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            
            Spacer()
        }
        .presentationDetents([.fraction(0.8)])
    }
}

#Preview {
    TransportHelpModal(isPresented: .constant(true), onConfirm: { _ in })
}
