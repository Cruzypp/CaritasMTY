//
//  TransportHelpCard.swift
//  caritas
//
//  Created by Cruz Yael Pérez González on 14/11/25.
//

import SwiftUI

struct TransportHelpCard: View {
    let needsHelp: Bool?
    @State private var showCallAlert = false
    
    private let phoneNumber = "2221903422"
    
    var body: some View {
        VStack(alignment: .leading){
            Text("Ayuda con traslado")
                .font(.gotham(.bold, style: .headline))
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    if let needsHelp = needsHelp {
                        if needsHelp {
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.aqua)
                                Text("Sí necesita ayuda")
                                    .font(.gotham(.regular, style: .body))
                                Spacer()
                            }
                        } else {
                            HStack {
                                Spacer()
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.morado)
                                Text("Lo hará por su cuenta")
                                    .font(.gotham(.regular, style: .body))
                                Spacer()
                            }
                        }
                    } else {
                        Text("No especificado")
                            .font(.gotham(.regular, style: .body))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                
                // Solo mostrar número si necesita ayuda
                if needsHelp == true {
                    Divider()
                    
                    VStack(spacing: 8) {
                        Text("Comunicarse al número:")
                            .font(.gotham(.bold, style: .caption))
                            .foregroundColor(.secondary)
                        
                        Button(action: { showCallAlert = true }) {
                            HStack {
                                Spacer()
                                Image(systemName: "phone.fill")
                                    .foregroundColor(.aqua)
                                Text(phoneNumber)
                                    .font(.gotham(.bold, style: .body))
                                    .foregroundColor(.azulMarino)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            .alert("Llamar", isPresented: $showCallAlert) {
                Button("Llamar") {
                    if let url = URL(string: "tel://\(phoneNumber)") {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancelar", role: .cancel) {}
            } message: {
                Text("¿Deseas llamar al número \(phoneNumber)?")
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    VStack(spacing: 16) {
        TransportHelpCard(needsHelp: true)
        TransportHelpCard(needsHelp: false)
        TransportHelpCard(needsHelp: nil)
    }
    .padding()
}
