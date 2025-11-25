//
//  BazaarPicker.swift
//  caritas
//
//  Created by Cruz Yael Pérez González on 09/11/25.
//

import SwiftUI

struct BazaarPicker: View {

    // Recibe el mismo ViewModel que usa DonateView
    @ObservedObject var donateViewModel: DonateViewModel

    // Bazar preseleccionado (si viene desde BazaarDetailView)
    var preselectedBazar: Bazar? = nil

    @StateObject private var homeViewModel = HomeViewModel()

    @State private var selectedOption: BazaarPickerOption? = nil

    // Alert cuando el bazar no acepta donaciones
    @State private var showClosedAlert = false
    @State private var closedBazarName: String = "Este bazar"

    // Lista convertida a opciones para la UI
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

                            // Ubicar bazar original
                            let bazar = homeViewModel.bazares.first { $0.id == option.id }
                            let isAccepting = bazar?.acceptingDonations ?? true

                            BazaarSelectionCard(
                                option: option,
                                isSelected: selectedOption?.id == option.id,
                                action: {

                                    if isAccepting {

                                        withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                            selectedOption = option
                                            donateViewModel.selectedBazarId = option.id
                                        }

                                    } else {
                                        closedBazarName = bazar?.nombre ?? "Este bazar"
                                        showClosedAlert = true
                                    }
                                }
                            )
                            .opacity(isAccepting ? 1.0 : 0.45)
                        }
                    }
                }
                .contentMargins(.vertical, 40)
                .scrollTargetBehavior(.viewAligned)
                .frame(height: 400)
                .mask(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .clear,
                            .white,
                            .white,
                            .clear
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .padding()

        // ============================
        //   PRESELECCIONAR BAZAR
        // ============================
        .onAppear {
            homeViewModel.fetchBazares()

            // Si viene un bazar desde BazaarDetailView
            if let pre = preselectedBazar {

                donateViewModel.selectedBazarId = pre.id   // se registra internamente
                selectedOption = BazaarPickerOption(from: pre) // se muestra visualmente
            }
        }

        // Alert cuando el bazar está cerrado
        .alert("Bazar no disponible", isPresented: $showClosedAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("\(closedBazarName) actualmente no está aceptando donaciones. Por favor elige otro bazar.")
        }
    }
}

#Preview {
    BazaarPicker(donateViewModel: DonateViewModel())
}
