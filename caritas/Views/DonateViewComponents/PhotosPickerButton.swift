import SwiftUI
import PhotosUI

struct PhotosPickerButton: View {
    @ObservedObject var viewModel: DonateViewModel
    @Binding var selectedPhotoItems: [PhotosPickerItem]

    var body: some View {
        PhotosPicker(selection: $selectedPhotoItems, maxSelectionCount: 8, matching: .images) {
            VStack(spacing: 10) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.title)
                    .foregroundColor(.naranja)
                Text("Selecciona 2 o más fotos")
                    .font(.gotham(.regular, style: .headline))
                    .foregroundColor(.azulMarino)
                Text("(\(viewModel.selectedImages.count)/10)")
                    .font(.gotham(.regular, style: .caption))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .padding(.horizontal, 10)
    }
}
