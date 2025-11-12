//
//  CameraButton.swift
//  caritas
//
//  Created by Cruz Yael Pérez González on 12/11/25.
//
import SwiftUI

struct CameraButton: View {
    @ObservedObject var viewModel: DonateViewModel
    @State private var showCamera = false
    
    var body: some View {
        Button(action: {
            if viewModel.canAddMorePhotos {
                showCamera = true
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 18, weight: .semibold))
                
                Text("Cámara")
                    .font(.gotham(.bold, style: .headline))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
        .buttonStyle(.glass)  // Aquí, inmediatamente después del Button
        .tint(Color.morado)   // Aquí, después del buttonStyle
        .disabled(!viewModel.canAddMorePhotos)
        .fullScreenCover(isPresented: $showCamera) {
            CameraView(images: $viewModel.selectedImages, maxPhotos: viewModel.maxPhotos)
                .ignoresSafeArea()
        }
    }
}

#Preview {
    CameraButton(viewModel: DonateViewModel())
}
