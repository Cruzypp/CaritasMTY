//  BazarAdminDonationsVM.swift

import Foundation
import Combine
import FirebaseFirestore

@MainActor
final class BazarAdminDonationsVM: ObservableObject {
    @Published var donations: [Donation] = []
    @Published var isLoading: Bool = false
    @Published var error: String?
    
    /// 🔥 Nuevo: si el bazar está aceptando donaciones o no
    @Published var isAcceptingDonations: Bool? = nil
    
    private var donationsListener: ListenerRegistration?
    private var bazarListener: ListenerRegistration?
    private let db = Firestore.firestore()

    func load(for bazarId: String) async {
        isLoading = true
        defer { isLoading = false }
        
        // Cargar datos iniciales
        do {
            let donations = try await FirestoreService.shared
                .fetchApprovedDonations(forBazarId: bazarId)
            let accepting = try await FirestoreService.shared
                .fetchBazarAcceptingDonations(bazarId: bazarId)
            
            self.donations = donations
            self.isAcceptingDonations = accepting
            self.error = nil
        } catch {
            self.error = error.localizedDescription
        }
        
        // Configurar listeners en tiempo real
        setupDonationsListener(bazarId: bazarId)
        setupBazarListener(bazarId: bazarId)
    }
    
    private func setupDonationsListener(bazarId: String) {
        // Detener listener anterior
        donationsListener?.remove()
        
        // Configurar nuevo listener para cambios en tiempo real
        donationsListener = db.collection("donations")
            .whereField("status", isEqualTo: "approved")
            .whereField("bazarId", isEqualTo: bazarId)
            .order(by: "day", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.error = error.localizedDescription
                    return
                }
                
                guard let snapshot = snapshot else { return }
                
                // Convertir documentos a Donation objects
                let donations = snapshot.documents.map { Donation.from(doc: $0) }
                self.donations = donations
                self.error = nil
            }
    }
    
    private func setupBazarListener(bazarId: String) {
        // Detener listener anterior
        bazarListener?.remove()
        
        // Configurar nuevo listener para cambios en estado del bazar
        bazarListener = db.collection("bazars")
            .document(bazarId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.error = error.localizedDescription
                    return
                }
                
                guard let data = snapshot?.data() else { return }
                let accepting = data["acceptingDonations"] as? Bool ?? true
                self.isAcceptingDonations = accepting
            }
    }
    
    func stopListening() {
        donationsListener?.remove()
        bazarListener?.remove()
        donationsListener = nil
        bazarListener = nil
    }
    
    deinit {
        donationsListener?.remove()
        bazarListener?.remove()
    }
}
