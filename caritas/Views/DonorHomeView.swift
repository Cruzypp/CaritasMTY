//
//  DonorHomeView.swift
//  caritas
//
//  Created by Juan Luis Alvarez Cisneros on 31/10/25.
//

import SwiftUI
import PhotosUI
import UIKit

struct DonorHomeView: View {
    @EnvironmentObject var donationVM: DonationViewModel
    @EnvironmentObject var auth: AuthViewModel              // ← para cerrar sesión

    // El picker vive en la View para no depender de PhotosUI en el ViewModel
    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var showLogoutConfirm = false            // ← confirmación opcional

    var body: some View {
        NavigationStack {
            List {
                
                NavigationLink{
                    HomeView()
                } label: {
                    Text("Home View")
                }
                // MARK: - Nueva donación
                Section("Nueva donación") {

                    // Selector de fotos + previews
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Sube al menos 2 fotos")
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        // Previews horizontales
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(Array(donationVM.images.enumerated()), id: \.offset) { _, img in
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipped()
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                }
                            }
                            .padding(.vertical, donationVM.images.isEmpty ? 0 : 4)
                        }

                        PhotosPicker(
                            selection: $pickerItems,
                            maxSelectionCount: 6,
                            matching: .images
                        ) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Añadir fotos")
                            }
                        }
                        // iOS 17+: firma con dos parámetros (oldValue, newValue)
                        .onChange(of: pickerItems) { _, newItems in
                            Task { await loadImages(from: newItems) }
                        }
                    }
                    .listRowSeparator(.hidden)

                    // Campos
                    TextField("Título", text: $donationVM.title)

                    TextField("Descripción", text: $donationVM.description, axis: .vertical)
                        .lineLimit(1...4)

                    TextField("Categorías (coma separadas) ej. ropa,comida",
                              text: $donationVM.categoryText)

                    TextField("Bazar (opcional, id)", text: Binding(
                        get: { donationVM.bazarId ?? "" },
                        set: { donationVM.bazarId = $0.isEmpty ? nil : $0 }
                    ))

                    Button(donationVM.isSending ? "Enviando..." : "Enviar donación") {
                        Task { await donationVM.sendDonation() }
                    }
                    .disabled(!donationVM.canSubmit)
                }

                // MARK: - Mis donaciones
                Section("Mis donaciones") {
                    if donationVM.loadingMy {
                        ProgressView()
                    } else if donationVM.myDonations.isEmpty {
                        Text("Aún no tienes donaciones.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(donationVM.myDonations) { d in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(d.title ?? "—").font(.headline)

                                if let desc = d.description, !desc.isEmpty {
                                    Text(desc).font(.subheadline).foregroundStyle(.secondary)
                                }

                                // Mini preview (primera foto)
                                if let urls = d.photoUrls,
                                   let first = urls.first,
                                   let url = URL(string: first) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(height: 120)
                                                .clipped()
                                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                        case .failure(_):
                                            EmptyView()
                                        case .empty:
                                            ProgressView().frame(height: 120)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                }

                                HStack {
                                    Text("Estado: \(d.status ?? "—")")
                                    if let cats = d.categoryId, !cats.isEmpty {
                                        Text("• \(cats.joined(separator: ", "))")
                                    }
                                }
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }

                if let msg = donationVM.message {
                    Section("Mensaje") { Text(msg).font(.footnote) }
                }
            }
            .navigationTitle("Donaciones")
            .toolbar {
                // Botón de logout (izquierda)
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        showLogoutConfirm = true
                    }) {
                        Image(systemName: "power.circle.fill")
                            .font(.title2)
                            .foregroundColor(.naranja)
                    }
                    .accessibilityLabel("Cerrar sesión")
                }

                // Botón de actualizar (derecha)
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        Task { await donationVM.loadMyDonations() }
                    }) {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .font(.title2)
                            .foregroundColor(.azulMarino)
                    }
                    .accessibilityLabel("Actualizar")
                }
            }
            .confirmationDialog("¿Cerrar sesión?", isPresented: $showLogoutConfirm, titleVisibility: .visible) {
                Button("Cerrar sesión", role: .destructive) {
                    auth.signOut()
                }
                Button("Cancelar", role: .cancel) { }
            }
            .task { await donationVM.loadMyDonations() }
        }
    }

    // Carga UIImage desde los PhotosPickerItem y los pasa al VM
    private func loadImages(from items: [PhotosPickerItem]) async {
        var result: [UIImage] = []
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let img = UIImage(data: data) {
                result.append(img)
            }
        }
        donationVM.images = result
    }
}

#Preview {
    // Stubs para que el canvas no truene
    let vm = DonationViewModel()
    vm.images = [UIImage(systemName: "photo")!, UIImage(systemName: "photo")!]
    return DonorHomeView()
        .environmentObject(AuthViewModel())   // ← importante para el Preview
        .environmentObject(vm)
}
