import SwiftUI

struct DescriptionSection: View {
    @ObservedObject var viewModel: DonateViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Descripción")
                .font(.gotham(.bold, style: .headline))
                .padding(.bottom, 4)

            ZStack(alignment: .topLeading) {
                // Placeholder
                if viewModel.description.isEmpty {
                    Text("Escribe una breve descripción...")
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 14)
                        .padding(.top, 10)
                        .font(.gotham(.regular, style: .subheadline))
                }

                // TextEditor
                TextEditor(text: $viewModel.description)
                    .scrollContentBackground(.hidden)
                    .font(.gotham(.regular, style: .subheadline))
                    .frame(minHeight: 100, maxHeight: 180)
                    .padding(.horizontal, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                    )
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

#Preview {
    DescriptionSection(viewModel: DonateViewModel())
}
