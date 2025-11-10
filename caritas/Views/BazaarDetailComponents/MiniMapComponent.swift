//
//  MiniMapComponent.swift
//  caritas
//
//  Created by Cruz Yael Pérez González on 09/11/25.
//

import Foundation
import SwiftUI
import MapKit

struct MiniMapComponent: View {
    
    var lat: Double
    var lon: Double
    var nombre: String
    
    var body: some View {
            ZStack {
                
                let location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                
                let markerCoordinate = location
                
                Map(position: .constant(.region(MKCoordinateRegion(
                    center: markerCoordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015))))) {
                        Marker(coordinate: location){
                            Text(nombre)
                        }
                        .tint(.aqua)
                    }
                .mapStyle(.standard)
                .disabled(true)
            }
    }
}

#Preview {
    MiniMapComponent(lat: 25.651782507136957, lon: -100.28943807606117, nombre: "Bazar")
}
