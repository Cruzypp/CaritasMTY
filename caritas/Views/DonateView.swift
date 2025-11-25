//
//  DonateView.swift
//  caritas
//
//  Created by Juan Luis Alvarez Cisneros on 05/11/25.
//

import SwiftUI
import PhotosUI
import FirebaseAuth

struct DonateView: View {
    @StateObject private var viewModel = DonateViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var showErrorAlert = false
    @State private var showValidDonation = false

    /// 👇 Bazar recibido desde BazaarDetailView
    var preselectedBazar: Bazar? = nil

    @StateObject private var categoryVM = CategorySelectorVM(maxSelection: nil)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // MARK: - Título
                    FormHeaderTitle()

                    // MARK: - Fotos
                    PhotoSourcePicker(viewModel: viewModel, selectedPhotoItems: $selectedPhotoItems)
                    SelectedImagesRow(viewModel: viewModel)

                    // MARK: - Título donación
                    TitleSection(viewModel: viewModel)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)

                    // MARK: - Descripción
                    DescriptionSection(viewModel: viewModel)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)

                    // MARK: - Categorías
                    CategorySelectorView(vm: categoryVM)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)

                    Divider().padding(.horizontal)

                    // MARK: - Picker de Bazares
                    BazaarPicker(
                        donateViewModel: viewModel,
                        preselectedBazar: preselectedBazar
                    )

                    Divider().padding(.horizontal)

                    // MARK: - Mensaje de éxito
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

            // Navegación a pantalla de éxito
            .navigationDestination(isPresented: $showValidDonation) {
                ValidDonationView()
            }
            .background(DonationBackground())
        }

        // MARK: - Alertas
        .alert("Error en la Donación", isPresented: $showErrorAlert) {
            Button("Aceptar", role: .cancel) { showErrorAlert = false }
        } message: {
            Text(viewModel.errorMessage ?? "Ocurrió un error desconocido")
        }

        // MARK: - Actualizar categorías
        .onChange(of: categoryVM.seleccionadas) {
            viewModel.selectedCategories = Array(categoryVM.seleccionadas.map(\.nombre))
        }

        // MARK: - Preseleccionar Bazar
        .onAppear {
            if let selected = preselectedBazar {
                viewModel.selectedBazarId = selected.id
            }
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }
}

#Preview {
    DonateView()
        .environmentObject(AuthViewModel())
}
