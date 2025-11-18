//
//  BaazarCard.swift
//  caritas
//
//  Created by Cruz Yael Pérez González on 04/11/25.
//

import SwiftUI

struct BaazarCard: View {
    
    let nombre: String
    let horarios: String
    let telefono: String
    /// 🔥 Nuevo: estado del bazar
    let isAcceptingDonations: Bool
    
    // Colores de estado
    private var statusBackground: Color {
        isAcceptingDonations
            ? Color.green.opacity(0.12)
        : Color(.yellow).opacity(0.20)
    }
    
    private var statusTextColor: Color {
        isAcceptingDonations
        ? Color.green.mix(with: .black, by: 0.20)
        : Color(.yellow).mix(with: .black, by: 0.25)
    }
    
    private var statusText: String {
        isAcceptingDonations
            ? "Actualmente está aceptando donaciones"
            : "Actualmente NO está aceptando donaciones"
    }
    
    var body: some View {
        HStack(alignment: .top) {
            
            // Columna principal
            VStack(alignment: .leading, spacing: 10) {
                
                // Nombre del bazar
                Text(nombre)
                    .font(.gotham(.bold, style: .title3))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(.morado))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                
                // Banner de estado
                HStack(spacing: 8) {
                    Image(systemName: isAcceptingDonations ? "checkmark.seal.fill" : "pause.circle.fill")
                        .font(.caption)
                        .foregroundStyle(statusTextColor)
                    
                    Text(statusText)
                        .font(.gotham(.regular, style: .caption))
                        .foregroundStyle(statusTextColor)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(statusBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                
                // Horarios y teléfono
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .top, spacing: 6) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        Text(horarios)
                            .font(.gotham(.regular, style: .caption))
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        Text(telefono)
                            .font(.gotham(.regular, style: .caption))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Icono de ubicación
            ZStack {
                Circle()
                    .fill(Color(.systemGray6))
                Image(systemName: "mappin.and.ellipse")
                    .font(.title2)
                    .foregroundStyle(Color(.morado))
            }
            .frame(width: 40, height: 40)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.systemGray6))
        )
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    VStack(spacing: 16) {
        BaazarCard(
            nombre: "Alameda",
            horarios: "Lunes a Viernes 9:30 a.m. a 6:30 p.m.; Sábados 10:00 a.m. a 6:00 p.m.",
            telefono: "81 8342 7680",
            isAcceptingDonations: true
        )
        .padding(.horizontal)
        
        BaazarCard(
            nombre: "Bernardo Reyes",
            horarios: "Lunes a Viernes 9:00 a.m. a 6:00 p.m.",
            telefono: "81 1357 3308",
            isAcceptingDonations: false
        )
        .padding(.horizontal)
    }
    .background(Color(.systemGroupedBackground))
}
