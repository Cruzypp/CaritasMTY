//
//  GalleryButton.swift
//  caritas
//
//  Created by Cruz Yael Pérez González on 12/11/25.
//

import SwiftUI
import PhotosUI

struct GalleryButton: View {
    @ObservedObject var viewModel: DonateViewModel
    @Binding var selectedPhotoItems: [PhotosPickerItem]
    
    var body: some View {
        PhotosPicker(
            selection: $selectedPhotoItems,
            maxSelectionCount: viewModel.remainingPhotos,
            matching: .images
        ) {
            HStack(spacing: 12) {
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 18, weight: .semibold))
                
                Text("Galería")
                    .font(.gotham(.bold, style: .headline))
            }
            .foregroundColor(.morado)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundColor(.white)
        }
        .disabled(!viewModel.canAddMorePhotos)
        .buttonStyle(.glass)
        
        .onChange(of: selectedPhotoItems) {
            Task { @MainActor in
                for item in selectedPhotoItems {
                    guard
                        let data = try? await item.loadTransferable(type: Data.self),
                        let uiImage = UIImage(data: data)
                    else { continue }
                    viewModel.selectedImages.append(uiImage)
                }
                selectedPhotoItems.removeAll()
            }
        }
    }
}

#Preview {
    GalleryButton(
        viewModel: DonateViewModel(),
        selectedPhotoItems: .constant([])
    )
}
