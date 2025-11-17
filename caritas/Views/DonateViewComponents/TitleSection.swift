import SwiftUI

struct TitleSection: View {
    @ObservedObject var viewModel: DonateViewModel
    @FocusState private var titleFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Título")
                .font(.gotham(.bold, style: .headline))
                .padding(.bottom)
            
            TextField("Ej: Ropa de invierno", text: $viewModel.title)
                .padding(8)
                .frame(height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                )
                .padding(.horizontal)
                .focused($titleFocused)
                .submitLabel(.done)
                .onSubmit { titleFocused = false }
        }
        .padding()
    }
}

#Preview {
    TitleSection(viewModel: DonateViewModel())
}
