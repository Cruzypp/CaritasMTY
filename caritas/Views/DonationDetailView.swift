//
//  DonationDetailView.swift
//  caritas
//

import SwiftUI
import MapKit
import FirebaseCore

struct DonationDetailView: View {

    let donation: Donation

    // ViewModels
    @StateObject private var detailVM: DonationDetailViewModel
    @EnvironmentObject var auth: AuthViewModel
    @StateObject private var adminVM = BazarAdminDonationsVM()

    // UI State
    @State private var showAllPhotos = false
    @State private var showConfirmAlert = false

    // Para regresar a la vista anterior (admin bazar)
    @Environment(\.dismiss) private var dismiss

    init(donation: Donation, isPreview: Bool = false) {
        self.donation = donation
        _detailVM = StateObject(
            wrappedValue: DonationDetailViewModel(
                donation: donation,
                isPreview: isPreview
            )
        )
    }

    private var isApproved: Bool {
        (donation.status ?? "").lowercased() == "approved"
    }

    private var isLargeItem: Bool {
        (donation.categoryId ?? []).contains { c in
            c.lowercased().contains("electro") || c.lowercased().contains("mueble")
        }
    }

    private var isDelivered: Bool {
        donation.isDelivered ?? false
    }

    /// ¿Está entrando como admin de bazar?
    private var isBazarAdmin: Bool {
        auth.role == "adminBazar"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // =========================
                // FOLIO
                // =========================
                Text("FOLIO: \(donation.folio ?? "—")")
                    .font(.gotham(.bold, style: .body))
                    .foregroundColor(.azulMarino)
                    .padding(.top, 20)
                    .frame(maxWidth: .infinity, alignment: .center)

                // =========================
                // GALERÍA
                // =========================
                gallerySection

                // =========================
                // INFO
                // =========================
                infoSection
                Divider().padding(.vertical, 10)

                // =========================
                // FEEDBACK
                // =========================
                feedbackSection
                Divider().padding(.vertical, 10)

                // =========================
                // TRANSPORTE
                // =========================
                if isLargeItem {
                    TransportHelpCard(needsHelp: donation.needsTransportHelp)
                    Divider().padding(.vertical, 10)
                }

                // =========================
                // BAZAR
                // =========================
                bazarSection
                Divider().padding(.vertical, 10)

                // =========================
                // UBICACIÓN
                // =========================
                locationSection
                Divider().padding(.vertical, 10)

                // =========================
                // QR (SOLO DONANTE)
                // =========================
                if isApproved,
                   !isBazarAdmin,                          // 👈 IMPORTANTE: solo si NO es admin de bazar
                   let qrCode = donation.qrCode {

                    VStack(alignment: .center, spacing: 16) {
                        QRDisplayView(
                            qrCodeBase64: qrCode,
                            donationId: donation.id ?? "",
                            folioNumber: donation.folio
                        )
                    }

                    Divider().padding(.vertical, 10)
                }

                // =========================
                // ACCIÓN ADMIN (SOLO ADMIN BAZAR)
                // =========================
                if isBazarAdmin {
                    adminActionSection
                }

            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAllPhotos) {
            AllPhotosSheetView(photoUrls: donation.photoUrls ?? [])
        }
        .onAppear {
            Task { await detailVM.loadBazarDetails() }
        }
        // Alerta para marcar como entregada (solo usada por admin)
        .alert("Marcar como entregada",
               isPresented: $showConfirmAlert) {

            Button("Cancelar", role: .cancel) {}

            Button("Marcar como entregada", role: .destructive) {
                Task {
                    await adminVM.markAsDelivered(donation)

                    // 🔥 Regresar a la lista después de marcar
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        dismiss()
                    }
                }
            }

        } message: {
            Text("¿Confirmas que la donación \"\(donation.title ?? "Sin título")\" fue entregada en el bazar?")
        }
    }
}



// ======================================================
// MARK: - SECCIONES
// ======================================================

extension DonationDetailView {

    // 📌 GALERÍA
    private var gallerySection: some View {
        VStack(spacing: 10) {
            if let urls = donation.photoUrls, !urls.isEmpty {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {

                    ForEach(Array(urls.prefix(3).enumerated()), id: \.offset) { _, urlString in
                        if let url = URL(string: urlString) {
                            Button { showAllPhotos = true } label: {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 140)
                                            .clipped()
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    default:
                                        ZStack {
                                            Color(.systemGray6)
                                            ProgressView()
                                        }
                                        .frame(height: 140)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                }
                            }
                        }
                    }

                    if urls.count > 3 {
                        Button { showAllPhotos = true } label: {
                            ZStack {
                                Color(.gray.opacity(0.85))
                                Text("+\(urls.count - 3)")
                                    .font(.title2.bold())
                                    .foregroundColor(.white)
                            }
                            .frame(height: 140)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
            }
        }
    }

    // 📌 INFO
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(donation.title ?? "Sin título")
                .font(.gotham(.bold, style: .title3))

            Text(donation.description ?? "Sin descripción")
                .font(.gotham(.regular, style: .callout))
                .foregroundColor(.secondary)

            HStack {
                Text("Estado:")
                    .font(.gotham(.bold, style: .body))

                Spacer()

                Text(statusLabel(donation.status ?? "pending"))
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(statusColor(donation.status ?? "pending"))
                    .foregroundColor(.white)
                    .cornerRadius(20)
            }
        }
    }

    // 📌 FEEDBACK
    private var feedbackSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Feedback")
                .font(.gotham(.bold, style: .headline))

            Text(donation.adminComment ?? "Sin comentarios")
                .font(.gotham(.regular, style: .body))
                .foregroundColor(.secondary)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
        }
    }

    // 📌 BAZAR
    private var bazarSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Bazar asignado")
                .font(.gotham(.bold, style: .headline))

            if isApproved {
                if let bazar = detailVM.bazar {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(bazar.nombre ?? "Bazar Cáritas")
                        Text(bazar.address ?? "")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                } else {
                    Text("No se pudo cargar la información del bazar.")
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }

            } else {
                Text("El bazar se mostrará cuando la donación sea aprobada.")
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }
        }
    }

    // 📌 UBICACIÓN
    private var locationSection: some View {
        Group {
            if isApproved,
               let bazar = detailVM.bazar,
               let lat = bazar.latitude,
               let lon = bazar.longitude {

                VStack(alignment: .leading, spacing: 8) {
                    Text("Ubicación")
                        .font(.gotham(.bold, style: .headline))

                    NavigationLink {
                        FullMapComponent(
                            nombre: bazar.nombre ?? "",
                            lat: lat,
                            lon: lon
                        )
                    } label: {
                        MapComponent(
                            nombre: bazar.nombre ?? "",
                            lat: lat,
                            lon: lon,
                            address: bazar.address ?? ""
                        )
                    }
                }

            } else if isApproved {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ubicación")
                        .font(.gotham(.bold, style: .headline))

                    Text("Ubicación no disponible.")
                        .font(.gotham(.regular, style: .body))
                        .foregroundColor(.secondary)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
            }
        }
    }

    // 📌 ACCIÓN ADMIN
    private var adminActionSection: some View {
        VStack{

            if isDelivered {
                Text("Esta donación ya fue entregada.")
                    .font(.gotham(.bold, style: .body))
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity, alignment: .center)

            } else {
                Button(action: { showConfirmAlert = true }) {
                    Text("Marcar como ENTREGADA")
                        .font(.gotham(.bold, style: .headline))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.aqua)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
        }
    }
}



// ======================================================
// MARK: - HELPERS
// ======================================================

extension DonationDetailView {

    private func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "pending": return .gray
        case "approved": return .aqua
        case "rejected": return .red
        default: return .gray
        }
    }

    private func statusLabel(_ status: String) -> String {
        switch status.lowercased() {
        case "pending": return "PENDIENTE"
        case "approved": return "APROBADA"
        case "rejected": return "RECHAZADA"
        default: return status.uppercased()
        }
    }
}


// MARK: - Preview

#Preview {
    let testDonation = Donation(
        id: "D001",
        bazarId: "Alameda",
        categoryId: ["Electrodomésticos", "Ferretería"],
        day: Timestamp(date: Date()),
        description: "X",
        adminComment: "Bien",
        folio: "e45b2500-c934-4126-8cea-4dbc83078fd7",
        photoUrls: [
            "https://picsum.photos/400/300",
            "https://picsum.photos/400/300",
            "https://picsum.photos/400/300",
            "https://picsum.photos/400/300"
        ],
        status: "approved",
        title: "Y x",
        userId: "U001",
        needsTransportHelp: true,
        qrCode: "MI_QR_BASE64_DE_EJEMPLO"
    )

    DonationDetailView(donation: testDonation, isPreview: true)
        .environmentObject(AuthViewModel())
}
