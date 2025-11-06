//
//  MapFullView.swift
//  caritas
//
//  Created by Cruz Yael Pérez González on 05/11/25.
//

import SwiftUI
import MapKit

struct MapFullView: View {
    let location: String
    @State private var position: MapCameraPosition = .automatic
    @Environment(\.dismiss) var dismiss
    
    let markerCoordinate = CLLocationCoordinate2D(latitude: 25.651782507136957, longitude: -100.28943807606117)
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Mapa con marcador en la ubicación exacta
                Map(position: $position) {
                    Annotation("", coordinate: markerCoordinate) {
                        VStack(spacing: 0) {
                            // Pin naranja
                            Image(systemName: "mappin")
                                .font(.system(size: 45))
                                .foregroundColor(.azulMarino)
                                .shadow(radius: 3)
                        }
                        .offset(y: -22) // Ajusta el pin para que la punta toque el punto
                    }
                }
                .mapStyle(.standard)
                .ignoresSafeArea()
                
                // Información en la parte inferior
                VStack {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        Text(location)
                            .font(.gotham(.bold, style: .headline))
                            .foregroundColor(.azulMarino)
                        
                        Text("Monterrey, Nuevo León")
                            .font(.gotham(.regular, style: .body))
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .padding()
                }
            }
            .navigationTitle("Ubicación")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Centrar en la ubicación del marcador con zoom más cercano
                position = .region(MKCoordinateRegion(
                    center: markerCoordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                ))
            }
        }
    }
}

#Preview {
    MapFullView(location: "Bazar")
}
