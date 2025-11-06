//
//  CategoryList.swift
//  caritas
//
//  Created by Cruz Yael Pérez González on 06/11/25.
//

import SwiftUI

enum iconos: String, CaseIterable {
    case deportes = "Deportes"
    case electrodomesticos = "Electrodomésticos"
    case electronica = "Electrónica"
    case ferreteria = "Ferretería"
    case juguetes = "Juguetes"
    case muebles = "Muebles"
    case personal = "Personal"
    
    var icon: String {
        switch self {
        case .deportes: return "figure.run"
        case .electrodomesticos: return "refrigerator"
        case .electronica: return "laptopcomputer"
        case .ferreteria: return "hammer.fill"
        case .juguetes: return "teddybear.fill"
        case .muebles: return "bed.double.fill"
        case .personal: return "person.fill"
        }
    }
    
}

struct CategoryList: View {
    @StateObject private var viewModel = DonateViewModel()
    @Environment(\.dismiss) var exit
    
    var body: some View {
        NavigationStack {
            
            Text("Categorias")
                .font(.gotham(.bold, style: .largeTitle))
                .padding(.horizontal, 15)
                .foregroundStyle(.azulMarino)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            List(viewModel.availableCategories, id: \.self) { option in
                Button {
                    toggle(option)
                } label: {
                    HStack {
                        
                        Image(systemName: getIcon(option))
                            .frame(width: 10, height: 10)
                            .padding(.trailing, 20)
                        
                        Text(option)
                        Spacer()
                        if viewModel.selectedCategories.contains(option) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Listo") {
                        exit()
                    }
                    .bold()
                }
            }
            .scrollContentBackground(.hidden)
            .padding(.horizontal, 15)
        }
    }
    
    private func toggle(_ option: String) {
        if viewModel.selectedCategories.contains(option) {
            viewModel.selectedCategories.removeAll { $0 == option }
        } else {
            viewModel.selectedCategories.append(option)
        }
    }
    
    private func getIcon(_ name: String) -> String {
        if let icono = iconos(rawValue: name) {
            return icono.icon
        }
        
        return ""
    }
}

#Preview {
    CategoryList()
}
