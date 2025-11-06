//
//  DonationViewModel.swift
//  caritas
//
//  Created by Juan Luis Alvarez Cisneros on 31/10/25.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore
import UIKit

@MainActor
final class DonationViewModel: ObservableObject {

    // MARK: - Form
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var categoryText: String = ""   // CSV: "ropa, comida"
    @Published var bazarId: String? = nil

    // MARK: - Photos (solo UIImages listos para subir)
    @Published var images: [UIImage] = []

    // MARK: - UI state
    @Published var isSending: Bool = false
    @Published var message: String?
    @Published var loadingMy: Bool = false

    // MARK: - Data
    @Published var myDonations: [Donation] = []

    private let db = Firestore.firestore()

    // Botón habilitado solo con título y 2+ fotos y sin envío en curso
    var canSubmit: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        images.count >= 2 &&
        !isSending
    }

    // MARK: - Enviar donación
    func sendDonation() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            message = "Necesitas iniciar sesión."
            return
        }
        guard canSubmit else {
            message = "Completa el título y agrega mínimo 2 fotos."
            return
        }

        isSending = true; defer { isSending = false }

        do {
            // 1) Crear doc base (sin fotos)
            let docId = try await FirestoreService.shared.createDonation(
                for: uid,
                title: title,
                description: description,
                categoryText: categoryText,
                bazarId: bazarId,
                photoUrls: [] // inicialmente vacío
            )

            // 2) Subir fotos a Storage
            let urls = try await StorageService.shared.uploadDonationImages(
                docId: docId,
                images: images,
                maxDimension: 1600,
                targetKB: 400
            )

            // 3) Guardar URLs en Firestore
            try await FirestoreService.shared.updateDonationPhotoURLs(docId: docId, urls: urls)

            message = "✅ Donación enviada."
            // reset del formulario
            title = ""; description = ""; categoryText = ""; bazarId = nil
            images = []
            await loadMyDonations()
        } catch {
            message = "❌ \(error.localizedDescription)"
        }
    }

    // MARK: - Mis donaciones
    func loadMyDonations() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        loadingMy = true; defer { loadingMy = false }
        do {
            myDonations = try await FirestoreService.shared.myDonations(for: uid)
        } catch {
            message = "❌ \(error.localizedDescription)"
        }
    }
}


