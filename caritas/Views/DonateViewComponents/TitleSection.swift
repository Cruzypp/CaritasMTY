import SwiftUI

struct TitleSection: View {
    @ObservedObject var viewModel: DonateViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Título")
                .font(.gotham(.bold, style: .headline))

            TextField("Ej: Ropa de invierno", text: $viewModel.title)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
        }
        .padding()
    }
}
