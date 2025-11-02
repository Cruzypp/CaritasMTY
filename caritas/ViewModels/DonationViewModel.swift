import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class DonationViewModel: ObservableObject {
    // Form
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var categoryText: String = ""   // CSV: "ropa, comida"
    @Published var bazarId: String? = nil

    // Estado UI
    @Published var isSending: Bool = false
    @Published var message: String?
    @Published var loadingMy: Bool = false

    // Datos
    @Published var myDonations: [Donation] = []

    private let db = Firestore.firestore()

    // MARK: – Actions

    func sendDonation() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            message = "Necesitas iniciar sesión."
            return
        }
        isSending = true; defer { isSending = false }

        do {
            _ = try await FirestoreService.shared.createDonation(
                for: uid,
                title: title,
                description: description,
                categoryText: categoryText,
                bazarId: bazarId
            )
            message = "✅ Donación enviada."
            // reset form
            title = ""; description = ""; categoryText = ""; bazarId = nil
            await loadMyDonations()
        } catch {
            message = "❌ \(error.localizedDescription)"
        }
    }

    func loadMyDonations() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        loadingMy = true; defer { loadingMy = false }
        do {
            myDonations = try await FirestoreService.shared.myDonations(for: uid)
        } catch {
            message = "❌ \(error.localizedDescription)"
        }
    }
}
