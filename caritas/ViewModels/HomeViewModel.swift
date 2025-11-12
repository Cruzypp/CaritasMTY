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
    
    func fetchBazares() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let bazaresData = try await firestoreService.fetchBazaars()
                self.bazares = bazaresData
                isLoading = false
            } catch {
                errorMessage = "Error al cargar bazares: \(error.localizedDescription)"
                isLoading = false
                print("Error fetching bazares: \(error)")
            }
        }
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
