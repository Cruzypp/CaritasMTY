//  BazarAdminDonationsVM.swift

import Foundation
import Combine
import FirebaseFirestore

@MainActor
final class BazarAdminDonationsVM: ObservableObject {
    @Published var donations: [Donation] = []
    @Published var isLoading: Bool = false
    @Published var error: String?
    
    /// 🔥 Si el bazar está aceptando donaciones o no
    @Published var isAcceptingDonations: Bool? = nil
    
    private var donationsListener: ListenerRegistration?
    private var bazarListener: ListenerRegistration?
    private let db = Firestore.firestore()

    // MARK: - Carga inicial + listeners

    func load(for bazarId: String) async {
        isLoading = true
        defer { isLoading = false }
        
        // Cargar datos iniciales una sola vez
        do {
            let donations = try await FirestoreService.shared
                .fetchApprovedDonations(forBazarId: bazarId)
            let accepting = try await FirestoreService.shared
                .fetchBazarAcceptingDonations(bazarId: bazarId)
            
            self.donations = donations
            self.isAcceptingDonations = accepting
            self.error = nil
        } catch {
            self.error = (error as NSError).localizedDescription
        }
        
        // Configurar listeners en tiempo real
        setupDonationsListener(bazarId: bazarId)
        setupBazarListener(bazarId: bazarId)
    }
    
    private func setupDonationsListener(bazarId: String) {
        // Detener listener anterior
        donationsListener?.remove()
        
        // Escuchar cambios en donaciones aprobadas de este bazar
        donationsListener = db.collection("donations")
            .whereField("status", isEqualTo: "approved")
            .whereField("bazarId", isEqualTo: bazarId)
            .order(by: "day", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.error = (error as NSError).localizedDescription
                    return
                }
                
                guard let snapshot = snapshot else { return }
                
                let donations = snapshot.documents.map { Donation.from(doc: $0) }
                self.donations = donations
                self.error = nil
            }
    }
    
    private func setupBazarListener(bazarId: String) {
        // Detener listener anterior
        bazarListener?.remove()
        
        // Escuchar cambios en el documento del bazar
        bazarListener = db.collection("bazars")
            .document(bazarId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.error = (error as NSError).localizedDescription
                    return
                }
                
                guard let data = snapshot?.data() else { return }
                let accepting = data["acceptingDonations"] as? Bool ?? true
                self.isAcceptingDonations = accepting
            }
    }
    
   
    // MARK: - Marcar donación como entregada

    /// Marca una donación como entregada en Firestore.
    /// Actualiza primero el arreglo local para que la UI reaccione al instante.
    /// El listener de `donations` después lo ajusta con los datos reales.
    func markAsDelivered(_ donation: Donation) async {
        guard let id = donation.id else { return }

        // Actualización optimista
        if let index = donations.firstIndex(where: { $0.id == id }) {
            donations[index].isDelivered = true
        }

        do {
            try await db.collection("donations")
                .document(id)
                .updateData([
                    "isDelivered": true,
                    "deliveredAt": FieldValue.serverTimestamp()
                ])
        } catch {
            if let index = donations.firstIndex(where: { $0.id == id }) {
                donations[index].isDelivered = false
            }
            let msg = (error as NSError).localizedDescription
            self.error = msg
            print("❌ Error al marcar como entregada: \(msg)")
        }
    }
    
    // MARK: - Limpieza de listeners
    
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
