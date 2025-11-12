import SwiftUI

struct SuccessMessageSection: View {
    @ObservedObject var viewModel: DonateViewModel

    var body: some View {
        if let successMessage = viewModel.successMessage {
            
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.green)
                    Text(successMessage)
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal)
        }
    }
}
