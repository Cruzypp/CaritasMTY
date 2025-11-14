import SwiftUI
import FirebaseAuth

struct RootView: View {
    @EnvironmentObject var auth: AuthViewModel

    var body: some View {
        Group {
            if auth.user == nil {
                ContentView() // tu ContentView dividido
            } else if auth.role == nil {
                // Aún cargando el perfil desde Firestore
                ProgressView("Cargando perfil…")
            } else if auth.isAdmin {
                AdminReviewsView()
            } else if auth.isBazarAdmin{
                BazarAdminDonationsView()
            } else {
                DonorHomeView()
            }
        }
        .animation(.default, value: auth.user?.uid)
    }
}
