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
    
    init(donation: Donation) {
        self.donation = donation
        _viewModel = StateObject(wrappedValue: DonationDetailViewModel(donation: donation))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // MARK: - Título
                    Text("FOLIO: \(donation.folio ?? "")")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.azulMarino)
                        .padding(.horizontal)
                        .padding(.top, 20)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
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
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 370, height: 300)
                                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                                    .tag(index)

                                            case .failure(_):
                                                Image(.logotipo)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(maxWidth: 370, maxHeight: 300)
                                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                                    .tag(index)

                                            case .empty:
                                                ProgressView()
                                                    .frame(width: 370, height: 300)
                                                    .tag(index)

                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                    }
                                }
                            }
                            .tabViewStyle(.page(indexDisplayMode: .automatic))
                            .frame(width: 370, height: 300)

                            // Miniaturas
                            if photoUrls.count > 1 {
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
                                                        .cornerRadius(8)
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
                                                        .scaledToFill()
                                                        .frame(width: 70, height: 70)
                                                        .cornerRadius(8)
                                                case .empty:
                                                    ProgressView()
                                                        .frame(width: 70, height: 70)
                                                @unknown default:
                                                    EmptyView()
                                                }
                                            }
                                        }
                                    }
                                    Spacer()
                                }
                                .padding(.leading, 20)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    // MARK: - Información de la Donación
                    VStack(alignment: .leading, spacing: 15) {
                        // Título y Descripción
                        VStack(alignment: .leading, spacing: 8) {
                            Text(donation.title ?? "Sin título")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            Text(donation.description ?? "Sin descripción")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .lineLimit(3)
                        }
                        
                        // Status
                        HStack {
                            Text("Estado:")
                                .fontWeight(.semibold)
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
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // MARK: - Comentario (Description)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Comentario")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text(donation.description ?? "Sin comentarios")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // MARK: - Bazar a Entregar
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Bazar a entregar")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        if let bazar = viewModel.bazar {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(bazar.location ?? "Ubicación desconocida")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                
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
                                .font(.body)
                                .foregroundColor(.secondary)
                                .padding()
                                .frame(width: 370)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // MARK: - Ubicación (Mapa)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ubicación")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        if let bazar = viewModel.bazar,
                           let location = bazar.location {
                            MapPreview(location: location)
                                .frame(height: 200)
                                .cornerRadius(10)
                        } else {
                            ZStack {
                                Color(.systemGray6)
                                Text("Ubicación no disponible")
                                    .foregroundColor(.secondary)
                            }
                            .frame(height: 200)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                }
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

// MARK: - MapPreview Component

struct MapPreview: View {
    let location: String
    @State private var position: MapCameraPosition = .automatic
    
    var body: some View {
        Map(position: $position)
            .mapStyle(.standard)
            .overlay(alignment: .center) {
                Image(systemName: "mappin.circle.fill")
                    .font(.title)
                    .foregroundColor(.naranja)
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
        description: "Donación de ropa en buen estado. Incluye abrigos, bufandas y suéteres.",
        folio: "FOL-001",
        photoUrls: [
            "https://firebasestorage.googleapis.com/v0/b/lostemplariosbackend.firebasestorage.app/o/donations%2FbZSA5wOLJFRo5J2skLKU%2Fphoto_0.heic?alt=media&token=8b5cf846-9cb7-4669-ba7d-853e42a59ee3",
            "https://firebasestorage.googleapis.com/v0/b/lostemplariosbackend.firebasestorage.app/o/donations%2FbZSA5wOLJFRo5J2skLKU%2Fphoto_0.heic?alt=media&token=8b5cf846-9cb7-4669-ba7d-853e42a59ee3"
        ],
        status: "pending",
        title: "Ropa de invierno",
        userId: "U001"
    )
    
    DonationDetailView(donation: testDonation)
}
