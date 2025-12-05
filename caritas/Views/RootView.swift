import SwiftUI
import FirebaseAuth

struct RootView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var showSplash = true

    var body: some View {
        ZStack {
            // ------- CONTENIDO REAL -------
            Group {
                if auth.user == nil {
                    ContentView()
                } else if auth.role == nil {
                    ProgressView("Cargando perfil…")
                } else if auth.isAdmin {
                    AdminReviewsView()
                } else if auth.isBazarAdmin {
                    BazarAdminDonationsView()
                } else {
                    DonorHomeView()
                }
            }
            // 👇 aparece suavemente cuando el splash se va
            .opacity(showSplash ? 0 : 1)
            .animation(.easeOut(duration: 0.45), value: showSplash)


            // ------- SPLASH ENCIMA -------
            if showSplash {
                Color.white.ignoresSafeArea()

                SplashView(isShowing: $showSplash)
                    // un pelín de zoom para que se vea más “pro”
                    .scaleEffect(showSplash ? 1 : 0.95)
                    .opacity(showSplash ? 1 : 0)
                    .animation(.easeInOut(duration: 0.45), value: showSplash)
            }
        }
        .onAppear {
            // cuánto tiempo quieres ver el splash
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                showSplash = false
            }
        }
    }
}
