import SwiftUI
import FirebaseAuth

struct SubmitButtonSection: View {
    @ObservedObject var viewModel: DonateViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var showErrorAlert: Bool
    @Binding var showValidDonation: Bool
    
    @State private var showTransportModal = false
    @State private var isProcessing = false
    
    /// Determina si necesita mostrar pantalla de transporte
    private var needsTransportScreen: Bool {
        viewModel.selectedCategories.contains { cat in
            cat.lowercased().contains("electrodoméstico") || 
            cat.lowercased().contains("electrodomestico") ||
            cat.lowercased().contains("mueble")
        }
    }
    
    private func submitDonation() {
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
    }

    var body: some View {
        Button(action: {
            if needsTransportScreen {
                // Mostrar modal de transporte
                showTransportModal = true
            } else {
                // Enviar directamente
                submitDonation()
            }
        }) {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                }
                Text(viewModel.isLoading ? "Subiendo..." : "Enviar Solicitud")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(.azulMarino)
            .cornerRadius(12)
            .padding(.horizontal, 10)
            .shadow(radius: 2)
        }
        .disabled(viewModel.isLoading || authViewModel.user == nil)
        .padding()
        .sheet(isPresented: $showTransportModal) {
            TransportHelpModal(
                isPresented: $showTransportModal,
                onConfirm: { needsHelp in
                    viewModel.needsTransportHelp = needsHelp
                    submitDonation()
                }
            )
        }
    }
}
