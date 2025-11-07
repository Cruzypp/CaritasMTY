import SwiftUI
import PhotosUI

struct PhotosPickerSection: View {
    @ObservedObject var viewModel: DonateViewModel
    @Binding var selectedPhotoItems: [PhotosPickerItem]

    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            PhotosPickerButton(viewModel: viewModel, selectedPhotoItems: $selectedPhotoItems)
        }
        .padding(.horizontal)
    }
}
