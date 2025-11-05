//
//  DonationDetailViewModel.swift
//  caritas
//
//  Created by Cruz Yael Pérez González on 04/11/25.
//

import Foundation
import FirebaseFirestore
import Combine

@MainActor
final class DonationDetailViewModel: ObservableObject {
    @Published var donation: Donation
    @Published var bazar: Bazar?
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private let firestoreService = FirestoreService.shared
    
    init(donation: Donation) {
        self.donation = donation
    }
    
    func loadBazarDetails() async {
        isLoading = true
        errorMessage = nil
        
        guard let bazarId = donation.bazarId else {
            isLoading = false
            return
        }
        
        do {
            // Intenta cargar el bazar desde Firestore
            let bazars = try await firestoreService.fetchBazaars()
            bazar = bazars.first { $0.id == bazarId }
        } catch {
            print("Error al cargar bazar: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
}
