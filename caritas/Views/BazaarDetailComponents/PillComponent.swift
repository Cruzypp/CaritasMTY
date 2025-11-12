//
//  PillComponent.swift
//  caritas
//
//  Created by Cruz Yael Pérez González on 07/11/25.
//

import SwiftUI

struct PillComponent: View {
    @State var categoria: String
    var body: some View {
        VStack{
            HStack(spacing: 8) {
                Text(categoria)
                    .font(.gotham(.regular, style: .caption))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.naranja.opacity(0.18))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(.naranja, lineWidth: 2)
            )
            
        }
    }
}

#Preview {
    let categoria = DonateViewModel.Categoria.electronica
    PillComponent(categoria: categoria.rawValue)
}
