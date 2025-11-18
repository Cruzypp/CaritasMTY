//
//  PrefetchingService.swift
//  caritas
//
//  Servicio para precargar datos y evitar esperas innecesarias
//

import Foundation
import FirebaseFirestore

@MainActor
final class PrefetchingService {
    static let shared = PrefetchingService()
    private init() {}
    
    private let firestoreService = FirestoreService.shared
    private var prefetchedBazars: [Bazar]? = nil
    private var prefetchedDonations: [Donation]? = nil
    
    /// Precarga bazares en background
    func prefetchBazars() {
        Task {
            do {
                self.prefetchedBazars = try await firestoreService.fetchBazaars()
            } catch {
                print("Error prefetching bazars: \(error)")
            }
        }
    }
    
    /// Obtiene bazares precargados o los carga si no existen
    func getBazars() async throws -> [Bazar] {
        if let cached = prefetchedBazars {
            return cached
        }
        let bazars = try await firestoreService.fetchBazaars()
        self.prefetchedBazars = bazars
        return bazars
    }
    
    /// Precarga donaciones aprobadas para un bazar específico
    func prefetchApprovedDonations(forBazarId bazarId: String) {
        Task {
            do {
                _ = try await firestoreService.approvedDonations(forBazarId: bazarId)
            } catch {
                print("Error prefetching approved donations: \(error)")
            }
        }
    }
    
    /// Invalida caché
    func invalidateCache() {
        prefetchedBazars = nil
        prefetchedDonations = nil
    }
}
