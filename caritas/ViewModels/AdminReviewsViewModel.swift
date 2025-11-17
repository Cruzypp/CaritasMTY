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
    
    private var lastSnapshot: DocumentSnapshot? = nil
    private let pageSize = 20

    func loadAll() async {
        isLoading = true
        errorMessage = nil
        lastSnapshot = nil
        do {
            let (donations, lastDoc) = try await FirestoreService.shared.pendingDonationsPaginated(limit: pageSize)
            self.donations = donations
            self.lastSnapshot = lastDoc
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func loadMore() async {
        guard let lastDoc = lastSnapshot else { return }
        isLoading = true
        do {
            let (donations, lastDoc) = try await FirestoreService.shared.pendingDonationsPaginated(limit: pageSize, startAfter: lastDoc)
            self.donations.append(contentsOf: donations)
            self.lastSnapshot = lastDoc
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
