//
//  BazaarPicker.swift
//  caritas
//
//  Created by Cruz Yael Pérez González on 09/11/25.
//

import SwiftUI

struct BazaarPicker: View {
    
    @StateObject private var homeViewModel = HomeViewModel()
    @State private var selectedOption: BazaarPickerOption? = nil

    // Alert cuando el bazar no acepta donaciones
    @State private var showClosedAlert = false
    @State private var closedBazarName: String = "Este bazar"
    
    var bazaarOptions: [BazaarPickerOption] {
        homeViewModel.bazares.map { BazaarPickerOption(from: $0) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Elige un Bazar")
                .font(.gotham(.bold, style: .headline))
            
            if homeViewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else if let error = homeViewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 8) {
                        ForEach(bazaarOptions) { option in
                            
                            // Buscamos el Bazar original para saber si acepta donaciones
                            let bazar = homeViewModel.bazares.first { $0.id == option.id }
                            let isAccepting = bazar?.acceptingDonations ?? true
                            
                            BazaarSelectionCard(
                                option: option,
                                isSelected: selectedOption?.id == option.id,
                                action: {
                                    if isAccepting {
                                        // Solo permitimos seleccionar si sí acepta donaciones
                                        withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                            selectedOption = option
                                        }
                                    } else {
                                        // Mostramos alerta si no acepta
                                        closedBazarName = bazar?.nombre ?? "Este bazar"
                                        showClosedAlert = true
                                    }
                                }
                            )
                            // Visualmente un poco apagado si no acepta donaciones
                            .opacity(isAccepting ? 1.0 : 0.45)
                        }
                    }
                }
                .contentMargins(.vertical, 40)
                .scrollTargetBehavior(.viewAligned)
                .frame(height: 200)
                .mask(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color.white,
                            Color.white,
                            Color.clear
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .padding()
        .onAppear {
            homeViewModel.fetchBazares()
        }
        // Alert cuando el bazar está “apagado”
        .alert("Bazar no disponible", isPresented: $showClosedAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("\(closedBazarName) actualmente no está aceptando donaciones. Por favor elige otro bazar.")
        }
    }
}

#Preview {
    BazaarPicker()
}
