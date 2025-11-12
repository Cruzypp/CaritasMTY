import SwiftUI

struct SelectedImagesRow: View {
    @ObservedObject var viewModel: DonateViewModel

    var body: some View {
        if !viewModel.selectedImages.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(viewModel.selectedImages.enumerated()), id: \.offset) { index, image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .cornerRadius(8)
                            .overlay(
                                Button {
                                    viewModel.selectedImages.remove(at: index)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(.red)
                                        .background(Circle().fill(Color.white))
                                }
                                .offset(x: 10, y: -10),
                                alignment: .topTrailing
                            )
                    }
                }
                .padding(.horizontal, 10)
                .padding(.top, 10)
            }
            .padding(.horizontal)
        }
    }
}
