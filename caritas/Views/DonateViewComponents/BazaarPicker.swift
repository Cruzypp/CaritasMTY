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
                            BazaarSelectionCard(
                                option: option,
                                isSelected: selectedOption?.id == option.id,
                                action: { selectedOption = option }
                            )
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
    }
}

#Preview {
    BazaarPicker()
}
