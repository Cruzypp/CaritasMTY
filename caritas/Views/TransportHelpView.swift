//
//  TransportHelpView.swift
//  caritas
//
//  Created by Cruz Yael Pérez González on 14/11/25.
//

import SwiftUI

struct TransportHelpView: View {
    @ObservedObject var viewModel: DonateViewModel
    @State private var navigateToSuccess = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()
                
                // MARK: - Icono/Emoji
                VStack(spacing: 20) {
                    Image(systemName: "truck.box.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.naranja)
                }
                
                // MARK: - Título
                VStack(spacing: 12) {
                    Text("¿Necesitas ayuda con el traslado?")
                        .font(.gotham(.bold, style: .title))
                        .foregroundColor(.azulMarino)
                    
                    Text("Podemos ayudarte a transportar tu donación")
                        .font(.gotham(.regular, style: .body))
                        .foregroundColor(.secondary)
                }
                
                // MARK: - Opciones
                VStack(spacing: 16) {
                    // Opción SÍ
                    Button(action: {
                        viewModel.needsTransportHelp = true
                        navigateToSuccess = true
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
                        viewModel.needsTransportHelp = false
                        navigateToSuccess = true
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
                .padding(.horizontal, 20)
                
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
                .padding(.horizontal, 20)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $navigateToSuccess) {
                ValidDonationView()
            }
        }
    }
}

#Preview {
    TransportHelpView(viewModel: DonateViewModel())
}
