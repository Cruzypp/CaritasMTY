import SwiftUI

struct SplashView: View {
    /// Controla si el splash se muestra o no (lo maneja el RootView)
    @Binding var isShowing: Bool
    
    // Animaciones internas
    @State private var logoScale: CGFloat = 0.9
    @State private var logoOpacity: Double = 0
    @State private var textOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Fondo (puede ser blanco plano o un degradado ultra suave)
            LinearGradient(
                colors: [
                    Color.white,
                    Color("azulMarino").opacity(0.03)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Logo principal (mismo asset que el LaunchScreen)
                Image("LaunchIcon")               // <- cambia el nombre si tu asset se llama distinto
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220)            // ajusta a gusto
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                
                VStack(spacing: 4) {
                    Text("Cáritas de Monterrey")
                        .font(.gotham(.bold, style: .title3))
                        .foregroundColor(Color("azulMarino"))
                    
                    Text("Conectando donantes con bazares")
                        .font(.gotham(.regular, style: .caption))
                        .foregroundColor(.secondary)
                }
                .opacity(textOpacity)
            }
        }
        .onAppear {
            // 1) Logo aparece con un pequeño zoom in
            withAnimation(.easeOut(duration: 0.45)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            
            // 2) Texto aparece un poquito después
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation(.easeInOut(duration: 0.35)) {
                    textOpacity = 1.0
                }
            }
            
            // 3) Mantenemos el splash un momento en pantalla
            let totalVisibleTime: Double = 1.2   // ajusta este valor si lo quieres más/menos tiempo
            
            DispatchQueue.main.asyncAfter(deadline: .now() + totalVisibleTime) {
                // Fade out suave de todo el contenido
                withAnimation(.easeInOut(duration: 0.35)) {
                    logoOpacity = 0.0
                    textOpacity = 0.0
                }
                
                // Cuando termina el fade, apagamos el splash
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    isShowing = false
                }
            }
        }
        // Accesibilidad: el logo es decorativo, el texto describe la pantalla
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Cáritas de Monterrey. Conectando donantes con bazares.")
    }
}
