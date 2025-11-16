//
//  TransportHelpCard.swift
//  caritas
//
//  Created by Cruz Yael Pérez González on 14/11/25.
//

import SwiftUI

struct TransportHelpCard: View {
    let needsHelp: Bool?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "truck.box.fill")
                    .font(.headline)
                    .foregroundColor(.naranja)
                
                Text("Ayuda con traslado")
                    .font(.gotham(.bold, style: .headline))
            }
            
            HStack {
                if let needsHelp = needsHelp {
                    if needsHelp {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.aqua)
                            Text("Sí necesita ayuda")
                                .font(.gotham(.regular, style: .body))
                        }
                    } else {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.grisOscuro)
                            Text("Lo hará por su cuenta")
                                .font(.gotham(.regular, style: .body))
                        }
                    }
                } else {
                    Text("No especificado")
                        .font(.gotham(.regular, style: .body))
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            Divider()
            
            VStack(spacing: 8) {
                Text("Contacto de ayuda:")
                    .font(.gotham(.bold, style: .caption))
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.naranja)
                    Text("2221903422")
                        .font(.gotham(.bold, style: .body))
                        .foregroundColor(.azulMarino)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
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
