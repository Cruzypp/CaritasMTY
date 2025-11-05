//
//  StatusViewModel.swift
//  caritas
//
//  Created by Cruz Yael Pérez González on 04/11/25.
//

import Foundation
import FirebaseFirestore
import Combine

@MainActor
final class StatusViewModel: ObservableObject {
    @Published var donations: [Donation] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private let firestoreService = FirestoreService.shared
    
    func loadDonations() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Intentar cargar desde Firestore con URLs de Storage
            donations = try await firestoreService.fetchDonationsWithStorageURLs()
            
            // Si está vacío, usar datos de prueba
            if donations.isEmpty {
                donations = getDummyDonations()
            }
        } catch {
            donations = getDummyDonations()
        }
        
        isLoading = false
    }
    
    private func getDummyDonations() -> [Donation] {
        [
            Donation(
                id: "D001",
                bazarId: "B001",
                categoryId: ["ropa", "invierno"],
                day: Timestamp(date: Date(timeIntervalSinceNow: -86400 * 2)),
                description: "Abrigos y bufandas en buen estado para donación de temporada.",
                folio: "FOL-001",
                photoUrls: [
                    "https://firebasestorage.googleapis.com/v0/b/lostemplariosbackend.firebasestorage.app/o/donations%2FbZSA5wOLJFRo5J2skLKU%2Fphoto_0.heic?alt=media&token=8b5cf846-9cb7-4669-ba7d-853e42a59ee3"
                ],
                status: "pending",
                title: "Ropa de invierno",
                userId: "U001"
            ),
            Donation(
                id: "D002",
                bazarId: "B002",
                categoryId: ["alimentos"],
                day: Timestamp(date: Date(timeIntervalSinceNow: -86400 * 7)),
                description: "Donación de alimentos no perecederos: arroz, frijoles, pasta y aceite.",
                folio: "FOL-002",
                photoUrls: [
                    "https://firebasestorage.googleapis.com/v0/b/lostemplariosbackend.firebasestorage.app/o/donations%2FbZSA5wOLJFRo5J2skLKU%2Fphoto_0.heic?alt=media&token=8b5cf846-9cb7-4669-ba7d-853e42a59ee3"
                ],
                status: "approved",
                title: "Despensa familiar",
                userId: "U002"
            ),
            Donation(
                id: "D003",
                bazarId: "B003",
                categoryId: ["juguetes", "infantil"],
                day: Timestamp(date: Date()),
                description: "Juguetes usados pero en excelente estado para campaña navideña.",
                folio: "FOL-003",
                photoUrls: [
                    "https://firebasestorage.googleapis.com/v0/b/lostemplariosbackend.firebasestorage.app/o/donations%2FbZSA5wOLJFRo5J2skLKU%2Fphoto_0.heic?alt=media&token=8b5cf846-9cb7-4669-ba7d-853e42a59ee3"
                ],
                status: "rejected",
                title: "Juguetes para niños",
                userId: "U003"
            )
        ]
    }
}
