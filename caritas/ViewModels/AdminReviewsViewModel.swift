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
    
    private var donationsListener: ListenerRegistration?
    private let db = Firestore.firestore()

    func loadAll() async {
        isLoading = true
        errorMessage = nil
        
        isLoading = false
        
        // Configurar listener en tiempo real
        setupDonationsListener()
    }
    
    private func setupDonationsListener() {
        // Detener listener anterior si existe
        donationsListener?.remove()
        
        // Configurar nuevo listener para TODAS las donaciones (sin filtro de status)
        donationsListener = db.collection("donations")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error en listener: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No hay documentos en snapshot")
                    return
                }
                
                print("Se recibieron \(documents.count) documentos totales")
                
                // Convertir documentos a Donation objects
                var allDonations: [Donation] = []
                for doc in documents {
                    let donation = Donation.from(doc: doc)
                    allDonations.append(donation)
                }
                
                // Ordenar por fecha descendente
                var sortedDonations = allDonations
                sortedDonations.sort { (a, b) -> Bool in
                    let ta = a.day?.dateValue() ?? .distantPast
                    let tb = b.day?.dateValue() ?? .distantPast
                    return ta > tb
                }
                
                self.donations = sortedDonations
                self.errorMessage = nil
            }
    }
    
    func stopListening() {
        donationsListener?.remove()
        donationsListener = nil
    }
    
    deinit {
        donationsListener?.remove()
    }
}
