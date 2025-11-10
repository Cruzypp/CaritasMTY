//
//  FullMapComponent.swift
//  caritas
//
//  Created by Cruz Yael Pérez González on 09/11/25.
//

import SwiftUI
import MapKit

struct FullMapComponent: View {
    
    
    @State private var showDirections = false
    
    var nombre: String
    var lat: Double
    var lon: Double
    
    var body: some View {
        let markerCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        
        ZStack(alignment: .bottom){
            Map(position: .constant(.region(MKCoordinateRegion(
                center: markerCoordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015))))) {
                    Marker(coordinate: markerCoordinate){
                        Text(nombre)
                    }
                    .tint(.aqua)
                }
                .mapStyle(.standard)
                .disabled(true)
            
            
            Button {
                showDirections.toggle()
            } label: {
                Label("Cómo llegar", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .shadow(radius: 4)
            }
            .confirmationDialog("Abrir en:", isPresented: $showDirections, titleVisibility: .visible) {
                Button("Apple Maps") { openInAppleMaps() }
                Button("Cancelar", role: .cancel) { }
            }
        }
    }
    
    func openInAppleMaps() {

        if let url = URL(string: "maps://?daddr=\(lat),\(lon)&dirflg=d") {
            UIApplication.shared.open(url)
            return
        }

        if let url = URL(string: "https://maps.apple.com/?daddr=\(lat),\(lon)&dirflg=d") {
            UIApplication.shared.open(url)
        }
    }
    
}

#Preview {
    FullMapComponent(nombre: "bazar", lat: 25.651782507136957, lon: -100.28943807606117)
}
