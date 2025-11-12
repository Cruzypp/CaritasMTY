//
//  Background.swift
//  caritas
//
//  Created by Cruz Yael Pérez González on 10/11/25.
//

import SwiftUI

struct DonationBackground: View {
    var body: some View {
        ZStack {
            // Fondo base oscuro para que los colores de lava resalten
            Color.azulMarino.opacity(0.2).edgesIgnoringSafeArea(.all)
            
            // "Gotas de lava" con color Aqua
            // Gota 1
            Ellipse()
                .fill(Color.aqua.opacity(0.4))
                .frame(width: 200, height: 350)
                .blur(radius: 120)
                .offset(x: -100, y: -200)
            
            // Gota 2
            Capsule() // Usamos Capsule para una forma más alargada
                .fill(Color.aqua.opacity(0.2))
                .frame(width: 150, height: 400)
                .blur(radius: 100)
                .offset(x: 150, y: 150)
            
            // Gota 3 (más clara o más pequeña)
            Circle()
                .fill(Color.aqua.opacity(0.9))
                .frame(width: 180, height: 180)
                .blur(radius: 110)
                .offset(x: -180, y: 300)
            
            // "Gotas de lava" con color Blanco (o un color contrastante como magenta)
            // Gota 4
            Ellipse()
                .fill(Color.white.opacity(0.9))
                .frame(width: 250, height: 280)
                .blur(radius: 130)
                .offset(x: 100, y: -300)
            
            // Gota 5
            Capsule()
                .fill(Color.white.opacity(0.9))
                .frame(width: 120, height: 250)
                .blur(radius: 90)
                .offset(x: -80, y: 100)
            
            // Puedes añadir más gotas y jugar con los colores, tamaños y posiciones.
            // Por ejemplo, un tono más oscuro de aqua:
            Circle()
                .fill(Color.aqua.opacity(0.2))
                .frame(width: 300, height: 300)
                .blur(radius: 150)
                .offset(x: 0, y: 0)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

// Asegúrate de que .aqua esté definido o usa un Color predefinido
/*
extension Color {
    static let aqua = Color(red: 0.0, green: 0.8, blue: 0.8)
}
*/

#Preview {
    DonationBackground()
}
