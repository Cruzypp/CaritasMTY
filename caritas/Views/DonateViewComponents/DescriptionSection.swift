import SwiftUI

struct DescriptionSection: View {
    @ObservedObject var viewModel: DonateViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Descripción")
                .font(.gotham(.bold, style: .headline))

            TextEditor(text: $viewModel.description)
                .frame(height: 100)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color(.systemGray3), lineWidth: 1)
                )
                .padding(.horizontal)
        }
        .padding()
    }
}
