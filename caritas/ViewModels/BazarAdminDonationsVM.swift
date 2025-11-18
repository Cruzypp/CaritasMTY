//  BazarAdminDonationsVM.swift

import Foundation
import Combine

@MainActor
final class BazarAdminDonationsVM: ObservableObject {
    @Published var donations: [Donation] = []
    @Published var isLoading: Bool = false
    @Published var error: String?
    
    /// 🔥 Nuevo: si el bazar está aceptando donaciones o no
    @Published var isAcceptingDonations: Bool? = nil

    func load(for bazarId: String) async {
        isLoading = true
        defer { isLoading = false }

        do {
            // Donaciones aprobadas para este bazar
            let donations = try await FirestoreService.shared
                .fetchApprovedDonations(forBazarId: bazarId)
            
            // Estado de acceptingDonations del bazar
            let accepting = try await FirestoreService.shared
                .fetchBazarAcceptingDonations(bazarId: bazarId)

            self.donations = donations
            self.isAcceptingDonations = accepting
            self.error = nil
        } catch {
            self.error = error.localizedDescription
        }
    }
}
