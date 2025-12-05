import SwiftUI
import PhotosUI

struct PhotoSourcePicker: View {
    @ObservedObject var viewModel: DonateViewModel
    @Binding var selectedPhotoItems: [PhotosPickerItem]
    
    var body: some View {
        VStack(spacing: 12) {
            // Botón Galería
            GalleryButton(
                viewModel: viewModel,
                selectedPhotoItems: $selectedPhotoItems
            )
            
            CameraButton(viewModel: viewModel)
            
            Text("(\(viewModel.selectedImages.count)/\(viewModel.maxPhotos))")
                .font(.gotham(.regular, style: .caption))
                .foregroundColor(.secondary)
                .padding(.top, 8)
            
            if !viewModel.canAddMorePhotos {
                Text("Límite alcanzado")
                    .font(.gotham(.regular, style: .caption2))
                    .foregroundColor(.red)
            }
        }
        .padding(.horizontal, 10)
    }
}

#Preview {
    PhotoSourcePicker(
        viewModel: DonateViewModel(),
        selectedPhotoItems: .constant([])
    )
}
