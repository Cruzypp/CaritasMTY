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
            LinearGradient(
                gradient: Gradient(colors: [ // Approximate color for the top
                    Color(.white.opacity(0.3)),// Approximate color for the bottom
                    Color(.aqua.opacity(0.5))
                ]),
                startPoint: .center,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.azulMarino.opacity(0.4), // Transparent white
                    Color.clear               // Fully transparent
                ]),
                center: .bottomLeading,
                startRadius: 5,
                endRadius: 400
            )
            .blendMode(.overlay)
            .edgesIgnoringSafeArea(.all)
        }
    }
}

#Preview {
    DonationBackground()
}


