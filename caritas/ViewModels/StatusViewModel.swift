//
//  StatusViewModel.swift
//  caritas
//
//  Created by Cruz Yael Pérez González on 04/11/25.
//

import Foundation
import FirebaseFirestore
import Combine
import FirebaseAuth

@MainActor
final class StatusViewModel: ObservableObject {
    @Published var donations: [Donation] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var selectedStatus: DonationStatus = .pending
    
    private let firestoreService = FirestoreService.shared
    private let isDummyMode: Bool
    
    init(isDummy: Bool = false) {
        self.isDummyMode = isDummy
        if isDummy {
            self.donations = Self.getDummyDonationsForPreview()
        }
    }
    
    enum DonationStatus: String, CaseIterable {
        case pending = "Pendiente"
        case rejected = "Rechazado"
        case approved = "Aprobado"
        case delivered = "Entregado"
        
        var firebaseValue: String {
            switch self {
            case .pending: return "pending"
            case .rejected: return "rejected"
            case .approved: return "approved"
            case .delivered: return "delivered"
            }
        }
    }
    
    var filteredAndSortedDonations: [Donation] {
        var filtered = donations
        
        // Filtrar por status
        if selectedStatus.firebaseValue == "delivered" {
            // Si buscamos "Entregado", filtramos solo por isDelivered = true
            filtered = filtered.filter { $0.isDelivered == true }
        } else {
            // Para cualquier otro status, filtramos por status coincidente
            // Y excluimos cualquier donación que ya esté entregada
            filtered = filtered.filter { 
                $0.status == selectedStatus.firebaseValue && $0.isDelivered != true
            }
        }
        
        // Ordenar por fecha (más recientes primero)
        filtered.sort { donation1, donation2 in
            let date1 = donation1.day?.dateValue() ?? Date.distantPast
            let date2 = donation2.day?.dateValue() ?? Date.distantPast
            return date1 > date2
        }
        
        return filtered
    }
    
    func loadDonations() async {
        // No cargar en modo dummy
        if isDummyMode { return }
        
        isLoading = true
        errorMessage = nil
        
        // Obtener el ID del usuario autenticado
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "No estás autenticado"
            isLoading = false
            return
        }
        
        do {
            // Cargar todas las donaciones
            var allDonations = try await firestoreService.fetchDonationsWithStorageURLs()
            
            // Filtrar solo las del usuario actual
            allDonations = allDonations.filter { $0.userId == userId }
            
            donations = allDonations
        } catch {
            donations = []
        }
        
        isLoading = false
    }
    
    // MARK: - Solo para Preview
    static func getDummyDonationsForPreview() -> [Donation] {
        let currentUserId = Auth.auth().currentUser?.uid ?? "U001"
        
        return [
            Donation(
                id: "D001",
                bazarId: "B001",
                categoryId: ["ropa", "invierno"],
                day: Timestamp(date: Date(timeIntervalSinceNow: -86400 * 2)),
                description: "Abrigos y bufandas en buen estado para donación de temporada.",
                folio: "FOL-001",
                photoUrls: [
                    "https://picsum.photos/400/300?random=1"
                ],
                status: "pending",
                title: "Ropa de invierno",
                userId: currentUserId
            ),
            Donation(
                id: "D002",
                bazarId: "B002",
                categoryId: ["alimentos"],
                day: Timestamp(date: Date(timeIntervalSinceNow: -86400 * 7)),
                description: "Donación de alimentos no perecederos: arroz, frijoles, pasta y aceite.",
                folio: "FOL-002",
                photoUrls: [
                    "https://picsum.photos/400/300?random=2"
                ],
                status: "approved",
                title: "Despensa familiar",
                userId: currentUserId
            ),
            Donation(
                id: "D003",
                bazarId: "B003",
                categoryId: ["juguetes", "infantil"],
                day: Timestamp(date: Date()),
                description: "Juguetes usados pero en excelente estado para campaña navideña.",
                folio: "FOL-003",
                photoUrls: [
                    "https://picsum.photos/400/300?random=3"
                ],
                status: "rejected",
                title: "Juguetes para niños",
                userId: currentUserId
            ),
            Donation(
                id: "D004",
                bazarId: "B001",
                categoryId: ["electrónica"],
                day: Timestamp(date: Date(timeIntervalSinceNow: -86400 * 15)),
                description: "Laptop en buen estado funcional.",
                folio: "FOL-004",
                photoUrls: [
                    "https://picsum.photos/400/300?random=4"
                ],
                status: "approved",
                title: "Laptop usada",
                userId: currentUserId,
                isDelivered: true
            )
        ]
    }
}

// MARK: - Preview Extension

extension StatusViewModel {
    static func previewWithDummyData() -> StatusViewModel {
        let vm = StatusViewModel()
        vm.donations = getDummyDonationsForPreview()
        return vm
    }
}
