//
//  MiniMapComponent.swift
//  caritas
//
//  Created by Cruz Yael Pérez González on 09/11/25.
//

import Foundation
import SwiftUI
import MapKit

struct MapComponent: View {
    
    var nombre: String
    var lat: Double
    var lon: Double
    var address: String
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            
            MiniMapComponent(lat: lat, lon: lon, nombre: nombre)
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemBackground).opacity(1),
                    Color.clear
                ]),
                startPoint: .bottom,
                endPoint: .center
            )
            
            AddressComponent(address: address)
        }
        .frame(width: 350, height: 250)
        .clipped()
        .clipShape(.rect(cornerRadius: 15))
        .shadow(radius: 3)
    }
}

#Preview {
    MapComponent(nombre: "bazar", lat: 25.651782507136957, lon: -100.28943807606117, address: "av. Miguel Hidalgo 1234, Ciudad de México")
}
