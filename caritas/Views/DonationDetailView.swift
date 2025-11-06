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
        _viewModel = StateObject(wrappedValue: DonationDetailViewModel(donation: donation, isPreview: isPreview))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // MARK: - Título
                    Text("FOLIO: \(donation.folio ?? "")")
                        .font(.gotham(.bold, style: .caption))
                        .foregroundColor(.azulMarino)
                        .padding(.top, 20)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    
                    // MARK: - Galería de Imágenes
                    VStack(spacing: 10) {
                        // Imagen principal
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
                                                        .frame(width: geometry.size.width, height: geometry.size.height)
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

                            // Miniaturas - Carrusel
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
                                                                        selectedImageIndex == index ? Color.naranja : Color.clear,
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
                                    .padding(.horizontal, 40)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    // MARK: - Información de la Donación
                    VStack(alignment: .leading, spacing: 15) {
                        // Título y Descripción
                        VStack(alignment: .leading, spacing: 8) {
                            Text(donation.title ?? "Sin título")
                                .font(.gotham(.bold, style: .title3))
                            
                            Text(donation.description ?? "Sin descripción")
                                .font(.gotham(.regular, style: .callout))
                                .foregroundColor(.secondary)
                                .lineLimit(3)
                        }
                        
                        // Status
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
                    .padding(.top, 40)
                    
                    Divider()
                        .padding(.vertical, 10)
                    
                    // MARK: - Comentario (Description)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Comentario")
                            .font(.gotham(.bold, style: .headline))
                        
                        Text(donation.description ?? "Sin comentarios")
                            .font(.gotham(.regular, style: .body))
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.secondary)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    
                    Divider()
                        .padding(.vertical, 10)
                    
                    // MARK: - Bazar a Entregar
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Bazar a entregar")
                            .font(.gotham(.bold, style: .headline))
                        
                        if let bazar = viewModel.bazar {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(bazar.location ?? "Ubicación desconocida")
                                    .font(.gotham(.regular, style: .body))
                                
                                if let address = bazar.address {
                                    Text(address)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        } else {
                            Text("Bazar no disponible")
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
                    
                    // MARK: - Ubicación (Mapa)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ubicación")
                            .font(.gotham(.bold, style: .headline))
                        
                        NavigationLink(destination: MapFullView(location: "Centro de Distribución Caritas")) {
                            ZStack {
                                // Minipreview del mapa con marcador
                                let markerCoordinate = CLLocationCoordinate2D(latitude: 25.651782507136957, longitude: -100.28943807606117)
                                
                                Map(position: .constant(.region(MKCoordinateRegion(
                                    center: markerCoordinate,
                                    span: MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
                                )))) {
                                    Annotation("", coordinate: markerCoordinate) {
                                        VStack(spacing: 0) {
                                            Image(systemName: "mappin")
                                                .font(.system(size: 32))
                                                .foregroundColor(.azulMarino)
                                                .shadow(radius:4)
                                        }
                                    }
                                }
                                .mapStyle(.standard)
                                .disabled(true)
                                .overlay{
                                    HStack{
                                        Text("Bazar Cáritas")
                                            .font(.gotham(.bold, style: .body))
                                            .foregroundStyle(Color.azulMarino)
                                            .frame(width: 140, height: 50)
                                            .background(Color.white)
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .offset(x: -95, y: -60)
                                    .shadow(color: .black, radius: 0.5)
                                    
                                }
                            }
                            .frame(height: 200)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.naranja.opacity(0.3), lineWidth: 1)
                            )
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
    
    // MARK: - Helper Functions
    
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
        bazarId: "B001",
        categoryId: ["ropa"],
        day: Timestamp(date: Date()),
        description: "ey.",
        folio: "FOL-001",
        photoUrls: [
            "https://picsum.photos/400/300"
        ],
        status: "pending",
        title: "Ropa de invierno",
        userId: "U001"
    )
    
    DonationDetailView(donation: testDonation, isPreview: true)
}
