//
//  ValidDonationView.swift
//  caritas
//
//  Created by Cruz Yael Pérez González on 05/11/25.
//

import SwiftUI

struct ValidDonationView: View {
    @State private var showConfetti = false
    @State private var navigateHome = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer()
                
                // MARK: - Confetti Animation
                VStack(spacing: 20) {
                    ZStack {
                        // Celebración de confeti (simulado con emojis)
                        VStack(spacing: 8) {
                            HStack(spacing: 16) {
                                Text("🎉")
                                    .font(.system(size: 40))
                                    .scaleEffect(showConfetti ? 1.2 : 0.8)
                                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: showConfetti)
                                
                                Text("🎊")
                                    .font(.system(size: 40))
                                    .scaleEffect(showConfetti ? 1.2 : 0.8)
                                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: showConfetti)
                                
                                Text("🎉")
                                    .font(.system(size: 40))
                                    .scaleEffect(showConfetti ? 1.2 : 0.8)
                                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: showConfetti)
                            }
                        }
                    }
                    
                    // Título
                    Text("¡Gracias!")
                        .font(.gotham(.bold, style: .title))
                        .foregroundColor(.azulMarino)
                }
                
                // MARK: - Mensaje
                VStack(spacing: 16) {
                    Text("Te notificaremos cuando tu donación haya sido revisada")
                        .frame(width: 250, height: 100)
                        .font(.gotham(.regular, style: .body))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                
                Spacer()
                
                // MARK: - Botón OK
                
                NavigationLink(destination: HomeView()) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.headline)
                        Text("Aceptar")
                            .font(.gotham(.bold, style: .headline))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.azulMarino)
                    .cornerRadius(12)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    navigateHome = true
                })
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
            .navigationBarBackButtonHidden(true)
        }
        .onAppear {
            withAnimation {
                showConfetti = true
            }
        }
    }
}

#Preview {
    ValidDonationView()
}
