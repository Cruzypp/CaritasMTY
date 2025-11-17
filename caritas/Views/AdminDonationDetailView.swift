//
//  AdminDonationDetailView.swift
//  caritas
//
//  Created by Juan Luis Alvarez Cisneros on 05/11/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore   // Timestamp
import Combine

struct AdminDonationDetailView: View {
    let donation: Donation
    @StateObject private var vm: AdminDonationDetailVM
    @State private var selectedImageIndex: Int = 0
    @State private var showAllPhotos: Bool = false
    
    init(donation: Donation) {
        self.donation = donation
        _vm = StateObject(wrappedValue: AdminDonationDetailVM(donation: donation))
    }
    
    // Colores desde Assets
    private let azul   = Color("azulMarino")
    private let aqua   = Color("aqua")
    private let naranja = Color("naranja")
    
    // Mismo criterio que DonationDetailView
    private var isLargeItem: Bool {
        guard let categories = donation.categoryId else { return false }
        return categories.contains { cat in
            cat.lowercased().contains("electrodoméstico") ||
            cat.lowercased().contains("electrodomestico") ||
            cat.lowercased().contains("mueble")
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // MARK: - Folio
                Text("FOLIO: \(donation.folio ?? "")")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(azul)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                // MARK: - Galería (replicada del donador: grid 2x2 + sheet)
                VStack(spacing: 10) {
                    if let photoUrls = donation.photoUrls, !photoUrls.isEmpty {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                            // Primeras 3 fotos
                            ForEach(Array(photoUrls.prefix(3).enumerated()), id: \.offset) { index, urlString in
                                if let url = URL(string: urlString) {
                                    Button(action: { showAllPhotos = true }) {
                                        AsyncImage(url: url) { phase in
                                            switch phase {
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 180, height: 150)
                                                    .clipped()
                                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                            case .failure(_):
                                                ZStack {
                                                    Color(.systemGray6)
                                                    Image(.logotipo)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 50, height: 50)
                                                }
                                                .frame(height: 150)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                            case .empty:
                                                ZStack {
                                                    Color(.systemGray6)
                                                    ProgressView()
                                                }
                                                .frame(height: 150)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // Botón "+N" en la 4ta posición
                            if photoUrls.count > 3 {
                                Button(action: { showAllPhotos = true }) {
                                    ZStack {
                                        Color(.gray.opacity(0.8))
                                        Text("+\(photoUrls.count - 3)")
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                    .frame(height: 150)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal)
                .sheet(isPresented: $showAllPhotos) {
                    AllPhotosSheetView(photoUrls: donation.photoUrls ?? [])
                }
                
                // MARK: - Información (título, descripción corta, estado)
                VStack(alignment: .leading, spacing: 15) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(donation.title ?? "Sin título")
                            .font(.headline.weight(.bold))
                        
                        Text(donation.description ?? "Sin descripción")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .lineLimit(3)
                    }
                    
                    HStack {
                        Text("Estado:")
                            .fontWeight(.semibold)
                        Spacer()
                        Text((vm.donation.status ?? "pending").uppercased())
                            .font(.caption.weight(.bold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(statusColor(vm.donation.status ?? "pending"))
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                Divider().padding(.horizontal)
                
                // MARK: - Ayuda con traslado (solo para electrodomésticos/muebles) - replicado
                if isLargeItem {
                    TransportHelpCard(needsHelp: donation.needsTransportHelp)
                        .padding(.horizontal)
                    
                    Divider().padding(.horizontal)
                }
                
                // MARK: - Comentario del admin
                VStack(alignment: .leading, spacing: 8) {
                    Text("Comentario para el donante (opcional)")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(azul)
                    
                    TextEditor(text: $vm.adminComment)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 120)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .padding(.horizontal)
                
                // MARK: - Acciones
                VStack(spacing: 12) {
                    Button {
                        Task { await vm.updateStatus(to: "approved") }
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text(vm.isWorking ? "Aprobando..." : "APROBAR")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(azul)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(vm.isWorking)
                    
                    Button(role: .destructive) {
                        Task { await vm.updateStatus(to: "rejected") }
                    } label: {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                            Text(vm.isWorking ? "Rechazando..." : "RECHAZAR")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemRed))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(vm.isWorking)
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Detalle")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: .init(get: { vm.errorMessage != nil }, set: { _ in vm.errorMessage = nil })) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(vm.errorMessage ?? "")
        }
        .overlay(alignment: .bottom) {
            if let toast = vm.toast {
                Text(toast)
                    .font(.callout.weight(.semibold))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(.bottom, 18)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: vm.toast)
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    // MARK: - Helpers
    private func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "pending":  return .gray
        case "approved": return aqua
        case "rejected": return .red
        default:         return .gray
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - ViewModel
@MainActor
final class AdminDonationDetailVM: ObservableObject {
    @Published var donation: Donation
    @Published var adminComment: String = ""
    @Published var isWorking = false
    @Published var errorMessage: String?
    @Published var toast: String?
    
    init(donation: Donation) {
        self.donation = donation
    }
    
    func updateStatus(to status: String) async {
        guard let id = donation.id else { return }
        isWorking = true; defer { isWorking = false }
        do {
            let reviewer = Auth.auth().currentUser?.uid ?? "unknown"
            try await FirestoreService.shared.setDonationStatus(
                donationId: id,
                status: status,
                reviewerId: reviewer
            )
            // Guarda comentario si hay
            let trimmed = adminComment.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                try? await FirestoreService.shared.db
                    .collection("donations").document(id)
                    .setData(["adminComment": trimmed], merge: true)
            }
            donation.status = status
            toast = status == "approved" ? "Donación aprobada" : "Donación rechazada"
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Preview
#Preview {
    let testDonation = Donation(
        id: "D001",
        bazarId: "B001",
        categoryId: ["Electrodomésticos", "muebles"],
        day: Timestamp(date: Date()),
        description: "Donación de ropa en buen estado. Incluye abrigos, bufandas y suéteres.",
        folio: "FOL-001",
        photoUrls: [
            "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?q=80&w=1200&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1526318472351-c75fcf070305?q=80&w=1200&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=1200&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1558981285-6f0c94958bb6?q=80&w=1200&auto=format&fit=crop",
            "https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=1200&auto=format&fit=crop"
        ],
        status: "pending",
        title: "Ropa de invierno",
        userId: "U001",
        needsTransportHelp: true
    )
    return NavigationStack {
        AdminDonationDetailView(donation: testDonation)
    }
}
