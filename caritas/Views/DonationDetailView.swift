//
//  DonationDetailView.swift
//  caritas
//
//  Created by Cruz Yael Pérez González on 04/11/25.
//

import SwiftUI
import MapKit
import FirebaseCore

struct DonationDetailView: View {
    let donation: Donation
    @StateObject private var viewModel: DonationDetailViewModel
    @State private var showAllPhotos: Bool = false
    
    init(donation: Donation, isPreview: Bool = false) {
        self.donation = donation
        _viewModel = StateObject(
            wrappedValue: DonationDetailViewModel(
                donation: donation,
                isPreview: isPreview
            )
        )
    }
    
    /// Cómodo para no repetir comparaciones
    private var isApproved: Bool {
        (donation.status ?? "").lowercased() == "approved"
    }
    
    /// Determina si es donación de electrodoméstico o mueble
    private var isLargeItem: Bool {
        guard let categories = donation.categoryId else { return false }
        return categories.contains { cat in
            cat.lowercased().contains("electrodoméstico") || 
            cat.lowercased().contains("electrodomestico") ||
            cat.lowercased().contains("mueble")
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // MARK: - Título (folio)
                    Text("FOLIO: \(donation.folio ?? "")")
                        .font(.gotham(.bold, style: .body))
                        .foregroundColor(.azulMarino)
                        .padding(.top, 20)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    
                    // MARK: - Galería de Imágenes (Grid 2x2)
                    VStack(spacing: 10) {
                        if let photoUrls = donation.photoUrls, !photoUrls.isEmpty {
                            // Grid de 2x2
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
                                                        .frame(width: 176, height: 140)
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
                                                    .frame(height: 140)
                                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                                    
                                                case .empty:
                                                    ZStack {
                                                        Color(.systemGray6)
                                                        ProgressView()
                                                    }
                                                    .frame(height: 140)
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
                                                .font(.gotham(.bold, style: .title2))
                                                .foregroundColor(.white)
                                        }
                                        .frame(height: 140)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    // MARK: - Info de la donación
                    VStack(alignment: .leading, spacing: 15) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(donation.title ?? "Sin título")
                                .font(.gotham(.bold, style: .title3))
                            
                            Text(donation.description ?? "Sin descripción")
                                .font(.gotham(.regular, style: .callout))
                                .foregroundColor(.secondary)
                                .lineLimit(3)
                        }
                        
                        HStack {
                            Text("Estado:")
                                .font(.gotham(.bold, style: .body))
                            Spacer()
                            Text(statusLabel(donation.status ?? "pending"))
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(statusColor(donation.status ?? "pending"))
                                .foregroundColor(.white)
                                .cornerRadius(20)
                        }
                    }
                    .padding(.top, 5)
                    
                    Divider()
                        .padding(.vertical, 10)
                    
                    // MARK: - Comentario del admin
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Feedback")
                            .font(.gotham(.bold, style: .headline))
                        
                        Text(donation.adminComment ?? "Sin comentarios")
                            .font(.gotham(.regular, style: .body))
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.secondary)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    
                    Divider()
                        .padding(.vertical, 10)
                    
                    // MARK: - Ayuda con traslado (solo para electrodomésticos/muebles)
                    if isLargeItem {
                        TransportHelpCard(needsHelp: donation.needsTransportHelp)
                        
                        Divider()
                            .padding(.vertical, 10)
                    }
                    
                    // MARK: - Bazar a entregar (solo si está aprobada)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Bazar a entregar")
                            .font(.gotham(.bold, style: .headline))
                        
                        if isApproved {
                            if let bazar = viewModel.bazar {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(bazar.nombre ?? bazar.location ?? "Bazar Cáritas")
                                        .font(.gotham(.regular, style: .body))
                                    
                                    if let address = bazar.address {
                                        Text(address)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    // Mensaje adicional si necesita ayuda con traslado y está aprobada
                                    if donation.needsTransportHelp == true {
                                        if let phone = bazar.telefono, !phone.isEmpty {
                                            Text("Por favor contactar al número telefónico: \(phone)")
                                                .font(.gotham(.regular, style: .callout))
                                                .foregroundColor(.secondary)
                                        } else {
                                            Text("Por favor contactar al número telefónico del bazar.")
                                                .font(.gotham(.regular, style: .callout))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            } else {
                                Text("No se pudo cargar la información del bazar.")
                                    .font(.gotham(.regular, style: .body))
                                    .foregroundColor(.secondary)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                            }
                        } else {
                            Text("El bazar se mostrará cuando tu donación sea aprobada.")
                                .font(.gotham(.regular, style: .body))
                                .foregroundColor(.secondary)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }
                    }
                    
                    Divider()
                        .padding(.vertical, 10)
                    
                    // MARK: - Ubicación (solo si está aprobada y hay bazar con coords)
                    if isApproved {
                        if let bazar = viewModel.bazar,
                           let lat = bazar.latitude,
                           let lon = bazar.longitude {
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Ubicación")
                                    .font(.gotham(.bold, style: .headline))
                                
                                NavigationLink {
                                    FullMapComponent(
                                        nombre: bazar.nombre ?? bazar.location ?? "Bazar Cáritas",
                                        lat: lat,
                                        lon: lon
                                    )
                                } label: {
                                    MapComponent(
                                        nombre: bazar.nombre ?? bazar.location ?? "Bazar Cáritas",
                                        lat: lat,
                                        lon: lon,
                                        address: bazar.address ?? "Sin dirección"
                                    )
                                }
                            }
                            
                            Divider()
                                .padding(.vertical, 10)
                        } else {
                            // Aprobada pero sin coordenadas
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Ubicación")
                                    .font(.gotham(.bold, style: .headline))
                                
                                Text("Ubicación no disponible.")
                                    .font(.gotham(.regular, style: .body))
                                    .foregroundColor(.secondary)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                            }
                            
                            Divider()
                                .padding(.vertical, 10)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showAllPhotos) {
                AllPhotosSheetView(photoUrls: donation.photoUrls ?? [])
            }
        }
        .task {
            await viewModel.loadBazarDetails()
        }
    }
    
    // MARK: - Helper
    
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
            "https://picsum.photos/400/300",
            "https://picsum.photos/400/300",
            "https://picsum.photos/400/300",
        ],
        status: "approved",
        title: "Y x",
        userId: "U001",
        needsTransportHelp: true
    )
    
    DonationDetailView(donation: testDonation, isPreview: true)
}
