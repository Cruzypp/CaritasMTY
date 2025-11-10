//
//  BazaarPickerOption.swift
//  caritas
//
//  Created by Cruz Yael Pérez González on 10/11/25.
//

import Foundation
import SwiftUI

struct BazaarPickerOption: Identifiable, Hashable {
    let id: String
    let nombre: String
    let address: String
    
    init(from bazar: Bazar) {
        self.id = bazar.id ?? UUID().uuidString
        self.nombre = bazar.nombre ?? "Sin nombre"
        self.address = bazar.address ?? "Sin dirección"
    }
}

struct BazaarSelectionCard: View {
    let option: BazaarPickerOption
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(option.nombre)
                        .font(.gotham(.bold, style: .body))
                        .foregroundStyle(isSelected ? .white : .black)
                    
                    Text(option.address)
                        .font(.gotham(.regular, style: .caption))
                        .foregroundStyle(isSelected ? .white.opacity(0.9) : .gray)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(.pin)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundStyle(isSelected ? .white : .naranja )
                
                Spacer()
            }
            .padding(12)
            .background(isSelected ? Color.morado.opacity(0.8) : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

#Preview {
    let option: BazaarPickerOption = .init(from: .init())
    BazaarSelectionCard( option: option, isSelected: true, action: {})
}
