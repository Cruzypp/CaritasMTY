import SwiftUI
import PhotosUI
import FirebaseAuth

struct DonateView: View {
    @StateObject private var viewModel = DonateViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var showErrorAlert = false
    @State private var showValidDonation = false

    @StateObject private var categoryVM = CategorySelectorVM(maxSelection: nil)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // MARK: - Título
                    FormHeaderTitle()
                    
                    // MARK: - Fotos
                    PhotosPickerSection(viewModel: viewModel, selectedPhotoItems: $selectedPhotoItems)
                    SelectedImagesRow(viewModel: viewModel)
                    
                    Divider().padding(.horizontal)
                    
                    // MARK: - Título donación
                    TitleSection(viewModel: viewModel)
                    
                    Divider().padding(.horizontal)
                    
                    // MARK: - Descripción
                    DescriptionSection(viewModel: viewModel)
                    
                    Divider().padding(.horizontal)
                    
                    // MARK: - Categorías (pasando VM)
                    CategorySelectorView(vm: categoryVM)
                    
                    Divider().padding(.horizontal)
                    
                    BazaarPicker()
                    
                    Divider().padding(.horizontal)
                    
                    // MARK: - Mensaje éxito
                    SuccessMessageSection(viewModel: viewModel)

                    // MARK: - Enviar
                    SubmitButtonSection(
                        viewModel: viewModel,
                        showErrorAlert: $showErrorAlert,
                        showValidDonation: $showValidDonation
                    )
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .onTapGesture { hideKeyboard() }

            // IMPORTANTE: la navegación cuelga del NavigationStack
            .navigationDestination(isPresented: $showValidDonation) {
                ValidDonationView()
            }
            .background(DonationBackground())
        }
        // Alertas y onChange pueden ir aquí
        .alert("Error en la Donación", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { showErrorAlert = false }
        } message: {
            Text(viewModel.errorMessage ?? "Ocurrió un error desconocido")
        }
        .onChange(of: selectedPhotoItems) {
            Task { @MainActor in
                for item in selectedPhotoItems {
                    guard
                        let data = try? await item.loadTransferable(type: Data.self),
                        let uiImage = UIImage(data: data)
                    else { continue }
                    viewModel.selectedImages.append(uiImage)
                }
                selectedPhotoItems.removeAll()
            }
        }
        .onChange(of: categoryVM.seleccionadas) {
            viewModel.selectedCategories = Array(categoryVM.seleccionadas.map(\.nombre))
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}

#Preview {
    DonateView()
        .environmentObject(AuthViewModel())
}
