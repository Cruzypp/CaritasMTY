
import SwiftUI

struct GlowBorderCard: View {
    // 1. Define tu gradiente (puedes cambiar los colores)
    let gradientColors = Gradient(colors: [Color.aqua, Color.azulMarino, Color.morado])
    
    var body: some View {
        ZStack {
            // Fondo oscuro para que resalte el glow
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Panel de Control")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Text("Estado: Activo")
                    .foregroundColor(.gray)
            }
            .padding(40)
            .background(.white)
            .cornerRadius(20)
            // --- AQUÍ EMPIEZA LA MAGIA ---
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(gradient: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 5
                    )
                    // El "Glow" es básicamente una sombra del mismo color que el borde
                    .shadow(color: .purple.opacity(0.8), radius: 10, x: 0, y: 0)
            )
        }
    }
}

struct GlowBorderCard_Previews: PreviewProvider {
    static var previews: some View {
        GlowBorderCard()
    }
}
