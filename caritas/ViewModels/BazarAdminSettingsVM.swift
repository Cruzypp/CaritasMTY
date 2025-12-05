//
//  BazarAdminSettingsVM.swift
//  caritas
//
//  Created by Juan Luis Alvarez Cisneros on 12/11/25.
//


//  BazarAdminSettingsVM.swift
import Combine
import Foundation

@MainActor
final class BazarAdminSettingsVM: ObservableObject {
    @Published var isAcceptingDonations: Bool = true
    @Published var isLoading: Bool = false
    @Published var error: String?

    func load(for bazarId: String) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let value = try await FirestoreService.shared.fetchBazarAcceptingDonations(bazarId: bazarId)
            self.isAcceptingDonations = value
            self.error = nil
        } catch {
            self.error = error.localizedDescription
        }
    }

    func save(for bazarId: String) async {
        do {
            try await FirestoreService.shared.updateBazarAcceptingDonations(
                bazarId: bazarId,
                isAccepting: isAcceptingDonations
            )
        } catch {
            self.error = error.localizedDescription
        }
    }
}
