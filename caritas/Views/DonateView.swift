//
//  DonateView.swift
//  caritas
//
//  Created by Cruz Yael Pérez González on 04/11/25.
//

import SwiftUI
import PhotosUI
import FirebaseAuth

struct DonateView: View {
    @StateObject private var viewModel = DonateViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var photosPickerPresented = false
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    @State private var showErrorAlert = false
    @State private var showValidDonation = false
    @State private var showPicker = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // MARK: - Título
                    Text("CREAR DONACIÓN")
                        .font(.gotham(.bold, style: .title))
                        .foregroundColor(.azulMarino)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 20)
                    
                    // MARK: - Selector de Fotos
                    VStack(alignment: .center, spacing: 15) {
                        PhotosPicker(selection: $selectedPhotoItems, maxSelectionCount: 8, matching: .images) {
                            VStack(spacing: 10) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.title)
                                    .foregroundColor(.naranja)
                                Text("Selecciona 2 o más fotos")
                                    .font(.gotham(.regular, style: .headline))
                                    .foregroundColor(.azulMarino)
                                Text("(\(viewModel.selectedImages.count)/10)")
                                    .font(.gotham(.regular, style: .caption))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 10)
                        
                        if !viewModel.selectedImages.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(Array(viewModel.selectedImages.enumerated()), id: \.offset) { index, image in
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 80, height: 80)
                                            .cornerRadius(8)
                                            .overlay(
                                                Button {
                                                    viewModel.selectedImages.remove(at: index)
                                                } label: {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .font(.title3)
                                                        .foregroundColor(.red)
                                                        .background(Circle().fill(Color.white))
                                                }
                                                .offset(x: 10, y: -10),
                                                alignment: .topTrailing
                                            )
                                    }
                                }
                                .padding(.horizontal, 10)
                                .padding(.top, 10)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // MARK: - Título de la Donación
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Título")
                            .font(.gotham(.bold, style: .headline))
                        
                        TextField("Ej: Ropa de invierno", text: $viewModel.title)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal)
                    }
                    .padding()
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // MARK: - Descripción
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
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // MARK: - Categorías
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
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // MARK: - Success Message
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
                    
                    // MARK: - Botón Enviar
                    Button(action: {
                        Task {
                            if let userId = authViewModel.user?.uid {
                                await viewModel.submitDonation(userId: userId)
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
                        .background(Color.naranja)
                        .cornerRadius(12)
                        .padding(.horizontal, 10)
                    }
                    .disabled(viewModel.isLoading || authViewModel.user == nil)
                    .padding()
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .onTapGesture {
                hideKeyboard()
            }
            .alert("Error en la Donación", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {
                    showErrorAlert = false
                }
            } message: {
                Text(viewModel.errorMessage ?? "Ocurrió un error desconocido")
            }
            .onChange(of: selectedPhotoItems) { oldValue, newValue in
                Task {
                    for item in newValue {
                        if let data = try? await item.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            viewModel.selectedImages.append(uiImage)
                        }
                    }
                    selectedPhotoItems = []
                }
            }
            .navigationDestination(isPresented: $showValidDonation) {
                ValidDonationView()
            }
            .sheet(isPresented: $showPicker) {
                CategoryList()
            }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

}

#Preview {
    DonateView()
        .environmentObject(AuthViewModel())
}
