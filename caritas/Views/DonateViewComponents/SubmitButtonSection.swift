import SwiftUI
import FirebaseAuth

struct SubmitButtonSection: View {
    @ObservedObject var viewModel: DonateViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var showErrorAlert: Bool
    @Binding var showValidDonation: Bool

    var body: some View {
        Button(action: {
            Task {
                if let userId = authViewModel.user?.uid {
                    await viewModel.submitDonation(userId: userId, bazarId: viewModel.selectedBazarId)
                    if viewModel.errorMessage != nil {
                        showErrorAlert = true
                    } else if viewModel.successMessage != nil {
                        showValidDonation = true
                    }
                } else {
                    viewModel.errorMessage = "Debes estar autenticado para donar"
                    showErrorAlert = true
                }
            }
        }) {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                }
                Text(viewModel.isLoading ? "Subiendo..." : "Enviar Donación")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(.azulMarino)
            .cornerRadius(12)
            .padding(.horizontal, 10)
        }
        .disabled(viewModel.isLoading || authViewModel.user == nil)
        .padding()
    }
}
