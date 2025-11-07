//
//  CategoryPill.swift
//  caritas
//
//  Created by Cruz Yael Pérez González on 07/11/25.
//

import SwiftUI

struct CategoryPill: View {
    let categoria: DonateViewModel.Categoria
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(categoria.nombre)
                    .font(.gotham(.regular, style: .callout))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? Color.naranja.opacity(0.18) : Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isSelected ? .naranja : Color.secondary.opacity(0.35), lineWidth: isSelected ? 2 : 1)
            )
            .animation(.spring(response: 0.25, dampingFraction: 0.85), value: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(categoria.nombre)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    let categoria = DonateViewModel.Categoria.electronica
    CategoryPill(categoria: categoria, isSelected: true, action: {} )
}
