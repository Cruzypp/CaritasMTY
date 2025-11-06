//
//  AdminReviewsViewModel.swift
//  caritas
//
//  Created by Juan Luis Alvarez Cisneros on 05/11/25.
//

import Foundation
import FirebaseFirestore
import Combine

@MainActor
final class AdminReviewsViewModel: ObservableObject {
    @Published var donations: [Donation] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadAll() async {
        isLoading = true
        errorMessage = nil
        do {
            // Usa tu servicio ya existente que trae TODAS las donaciones
            var all = try await FirestoreService.shared.fetchDonations()
            // Ordena por fecha (day desc) cuando exista el timestamp
            all.sort { (a, b) -> Bool in
                let ta = a.day?.dateValue() ?? .distantPast
                let tb = b.day?.dateValue() ?? .distantPast
                return ta > tb
            }
            donations = all
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
