//
//  DonateViewModel.swift
//  caritas
//
//  Created by Cruz Yael Pérez González on 04/11/25.
//

import Foundation
import UIKit
import Combine

final class DonateViewModel: ObservableObject {

    // MARK: - Datos de la donación
    @Published var selectedImages: [UIImage] = []
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var selectedCategories: [String] = []

    /// 🔥 NUEVO: almacena el bazar preseleccionado que viene desde BazaarDetailView
    @Published var preselectedBazar: Bazar? = nil

    /// ID del bazar seleccionado (ya sea manual o preseleccionado)
    @Published var selectedBazarId: String? = nil

    @Published var needsTransportHelp: Bool = false
    
    // MARK: - Estado UI
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil
    
    private let firestoreService = FirestoreService.shared
    private let storageService = StorageService.shared
    
    // MARK: - Límites de fotos
    let maxPhotos: Int = 10
    
    var remainingPhotos: Int {
        max(0, maxPhotos - selectedImages.count)
    }
    
    var canAddMorePhotos: Bool {
        selectedImages.count < maxPhotos
    }
    
    enum Categoria: String, CaseIterable, Hashable {
        case deportes = "Deportes"
        case electrodomesticos = "Electrodomésticos"
        case electronica = "Electrónica"
        case ferreteria = "Ferretería"
        case juguetes = "Juguetes"
        case muebles = "Muebles"
        case personal = "Personal"
        
        var nombre: String { self.rawValue }
    }
    
    // MARK: - VALIDACIÓN
    func validateDonation() -> Bool {
        
        guard selectedImages.count >= 2 else {
            errorMessage = "Debes seleccionar al menos 2 fotos"
            return false
        }
        
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "El título es obligatorio"
            return false
        }
        
        guard !selectedCategories.isEmpty else {
            errorMessage = "Selecciona al menos una categoría"
            return false
        }
        
        guard selectedBazarId != nil,
              !(selectedBazarId?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        else {
            errorMessage = "Selecciona un bazar de entrega"
            return false
        }
        
        return true
    }
    
    
    // MARK: - SUBMIT DONACIÓN
    @MainActor
    func submitDonation(userId: String, bazarId: String? = nil) async {
        guard validateDonation() else { return }
        
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        do {
            // Crear la donación
            let donationId = try await firestoreService.createDonation(
                for: userId,
                title: title,
                description: description,
                categoryText: selectedCategories.joined(separator: ", "),
                bazarId: bazarId ?? selectedBazarId,
                photoUrls: [],
                needsTransportHelp: needsTransportHelp
            )
            
            // Subir fotos
            let photoUrls = try await storageService.uploadDonationImages(
                docId: donationId,
                images: selectedImages,
                maxDimension: 1600,
                targetKB: 350
            )
            
            // Actualizar documento con URLs
            try await firestoreService.updateDonationPhotoURLs(
                docId: donationId,
                urls: photoUrls
            )
            
            successMessage = "¡Donación enviada exitosamente!"
            resetForm()
            
        } catch {
            errorMessage = "Error al enviar la donación: \(error.localizedDescription)"
            print("Error en submitDonation: \(error)")
        }
        
        isLoading = false
    }
    
    
    // MARK: - Resetear UI
    private func resetForm() {
        selectedImages = []
        title = ""
        description = ""
        selectedCategories = []
        selectedBazarId = nil
        preselectedBazar = nil
        needsTransportHelp = false
    }
    
    // MARK: - Categorías
    func toggleCategory(_ category: String) {
        if selectedCategories.contains(category) {
            selectedCategories.removeAll { $0 == category }
        } else {
            selectedCategories.append(category)
        }
    }
}
