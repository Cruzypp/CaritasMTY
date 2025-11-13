// BazarAdminDonationsVM.swift

import Foundation
import Combine

@MainActor
final class BazarAdminDonationsVM: ObservableObject {
    @Published var donations: [Donation] = []
    @Published var isLoading = false
    @Published var error: String?

    func load(for bazarId: String) async {
        isLoading = true
        defer { isLoading = false }

        do {
            donations = try await FirestoreService.shared.fetchApprovedDonations(forBazarId: bazarId)
            error = nil
        } catch {
            self.error = error.localizedDescription
        }
    }
}
