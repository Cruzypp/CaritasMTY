//
//  HomeViewModel.swift
//  caritas
//
//  Created by GitHub Copilot on 07/11/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var bazares: [Bazar] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let firestoreService = FirestoreService.shared
    private var bazaresCache: [Bazar]? = nil
    private var cacheTimestamp: Date? = nil
    private let cacheDuration: TimeInterval = 300 // 5 minutos
    
    func fetchBazares() {
        // Usar caché si está disponible y no ha expirado
        if let cached = bazaresCache, let timestamp = cacheTimestamp,
           Date().timeIntervalSince(timestamp) < cacheDuration {
            self.bazares = cached
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let bazaresData = try await firestoreService.fetchBazaars()
                self.bazares = bazaresData
                self.bazaresCache = bazaresData
                self.cacheTimestamp = Date()
                isLoading = false
            } catch {
                errorMessage = "Error al cargar bazares: \(error.localizedDescription)"
                isLoading = false
                print("Error fetching bazares: \(error)")
            }
        }
    }
    
    func invalidateCache() {
        bazaresCache = nil
        cacheTimestamp = nil
    }
    
    func searchBazares(query: String) -> [Bazar] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return bazares
        }
        
        let q = query.lowercased()
        return bazares.filter { bazar in
            (bazar.nombre?.lowercased().contains(q) ?? false) ||
            (bazar.address?.lowercased().contains(q) ?? false) ||
            (bazar.location?.lowercased().contains(q) ?? false) ||
            (bazar.telefono?.lowercased().contains(q) ?? false)
        }
    }
}
