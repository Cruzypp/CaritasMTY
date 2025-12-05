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

                // MARK: Galería
                GallerySection(photoUrls: donation.photoUrls)
                    .padding(.horizontal)

                // MARK: Información
                InfoSection(donation: donation)
                
                Divider().padding(.vertical, 10)

                // MARK: Feedback
                FeedbackSection(adminComment: donation.adminComment)
                Divider().padding(.vertical, 10)

                // MARK: Transporte
                if isLargeItem {
                    TransportHelpCard(needsHelp: donation.needsTransportHelp)
                    Divider().padding(.vertical, 10)
                }

                // MARK: Bazar
                BazarSection(
                    isApproved: isApproved,
                    bazar: detailVM.bazar,
                    isLoading: detailVM.isLoading
                )
                Divider().padding(.vertical, 10)

                // MARK: Ubicación
                LocationSection(isApproved: isApproved, bazar: detailVM.bazar)
                    .padding(.horizontal)
                Divider().padding(.vertical, 10)

                // MARK: QR de Donante
                if isApproved && !isBazarAdmin,
                   let qrCode = donation.qrCode {

                    VStack(alignment: .center, spacing: 16) {
                        QRDisplayView(
                            qrCodeBase64: qrCode,
                            donationId: donation.id ?? "",
                            folioNumber: donation.folio
                        )
                    }
                    .padding()

                    Divider().padding(.vertical, 10)
                }

                
                if isBazarAdmin {
                    AdminActionSection(
                        isDelivered: isDelivered,
                        donation: donation,
                        onMarkDelivered: { showConfirmAlert = true }
                    )
                        .padding(.horizontal)
                }

            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
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
