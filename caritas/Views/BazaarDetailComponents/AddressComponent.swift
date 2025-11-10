//
//  AddressComponent.swift
//  caritas
//
//  Created by Cruz Yael Pérez González on 09/11/25.
//

import SwiftUI

struct AddressComponent: View {
    
    var address: String
    
    var body: some View {
        GroupBox {
            Text(address)
                .font(.gotham(.regular, style: .subheadline))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "location.circle.fill")
                    .resizable()
                    .frame(width: 22, height: 22)
                    .foregroundColor(.aqua)
                Text("Dirección")
                    .font(.gotham(.bold, style: .headline))
                Spacer()
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
        )
    }
}

#Preview {
    let address = "Florencio Antillón 1223, Centro, Monterrey, N.L., C.P 64720"
    AddressComponent( address: address )
        .padding()
}
