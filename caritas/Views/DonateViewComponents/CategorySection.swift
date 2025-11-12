import SwiftUI

struct CategorySection: View {
    @ObservedObject var viewModel: DonateViewModel
    @Binding var showPicker: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Categoría")
                .font(.gotham(.bold, style: .headline))
                .padding(.horizontal)

            Button {
                showPicker.toggle()
            } label: {
                HStack {
                    if viewModel.selectedCategories.isEmpty {
                        Text("Ninguna")
                            .foregroundStyle(.secondary)
                    } else {
                        Text(viewModel.selectedCategories.joined(separator: ", "))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            .foregroundStyle(.black)
            .padding(.horizontal)
        }
        .padding()
    }
}

