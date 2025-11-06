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
    private let isPreview: Bool
    
    init(donation: Donation, isPreview: Bool = false) {
        self.donation = donation
        self.isPreview = isPreview
    }
    
    func loadBazarDetails() async {
        // No cargar datos en preview
        if isPreview { return }
        
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
