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
    @State private var selectedImageIndex: Int = 0
    
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
                    
                    // MARK: - Galería de Imágenes
                    VStack(spacing: 10) {
                        if let photoUrls = donation.photoUrls, !photoUrls.isEmpty {
                            TabView(selection: $selectedImageIndex) {
                                ForEach(Array(photoUrls.enumerated()), id: \.offset) { index, urlString in
                                    if let url = URL(string: urlString) {
                                        AsyncImage(url: url) { phase in
                                            switch phase {
                                            case .success(let image):
                                                GeometryReader { geometry in
                                                    image
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(
                                                            width: geometry.size.width,
                                                            height: geometry.size.height
                                                        )
                                                        .clipped()
                                                }
                                                .frame(height: 300)
                                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                                .tag(index)
                                                
                                            case .failure(_):
                                                ZStack {
                                                    Color(.systemGray6)
                                                    Image(.logotipo)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 150, height: 150)
                                                }
                                                .frame(height: 300)
                                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                                .tag(index)
                                                
                                            case .empty:
                                                ZStack {
                                                    Color(.systemGray6)
                                                    ProgressView()
                                                }
                                                .frame(height: 300)
                                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                                .tag(index)
                                                
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                    }
                                }
                            }
                            .tabViewStyle(.page(indexDisplayMode: .automatic))
                            .frame(height: 300)
                            
                            // Miniaturas
                            if photoUrls.count > 1 {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(Array(photoUrls.enumerated()), id: \.offset) { index, urlString in
                                            if let url = URL(string: urlString) {
                                                AsyncImage(url: url) { phase in
                                                    switch phase {
                                                    case .success(let image):
                                                        image
                                                            .resizable()
                                                            .scaledToFill()
                                                            .frame(width: 70, height: 70)
                                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                                            .overlay(
                                                                RoundedRectangle(cornerRadius: 8)
                                                                    .stroke(
                                                                        selectedImageIndex == index
                                                                        ? Color.naranja
                                                                        : Color.clear,
                                                                        lineWidth: 2
                                                                    )
                                                            )
                                                            .onTapGesture {
                                                                selectedImageIndex = index
                                                            }
                                                    case .failure(_):
                                                        Image(.logotipo)
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 70, height: 70)
                                                            .background(Color(.systemGray6))
                                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                                    case .empty:
                                                        ProgressView()
                                                            .frame(width: 70, height: 70)
                                                    @unknown default:
                                                        EmptyView()
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 2)
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
                            Text((donation.status ?? "pending").uppercased())
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
            "https://picsum.photos/400/300"
        ],
        status: "approved",
        title: "Y x",
        userId: "U001"
    )
    
    DonationDetailView(donation: testDonation, isPreview: true)
}
