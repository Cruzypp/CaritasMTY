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
        
        // Si es preview, asignar un bazar dummy
        if isPreview {
            self.bazar = Bazar(
                id: "bazar-dummy",
                address: "Av. Alameda 123, Ciudad de México",
                location: "Alameda Centro",
                nombre: "Bazar Alameda",
                latitude: 19.4326,
                longitude: -99.1332,
                telefono: "+52 1 55 1234 5678"
            )
        }
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
