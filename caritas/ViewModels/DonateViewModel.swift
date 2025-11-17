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
    @Published var selectedImages: [UIImage] = []
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var selectedCategories: [String] = []
    @Published var selectedBazarId: String? = nil
    @Published var needsTransportHelp: Bool = false
    
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil
    
    private let firestoreService = FirestoreService.shared
    private let storageService = StorageService.shared
    
    // Límite máximo de fotos permitidas
    let maxPhotos: Int = 10
    
    // Calcula cuántas fotos más se pueden agregar
    var remainingPhotos: Int {
        max(0, maxPhotos - selectedImages.count)
    }
    
    // Verifica si se pueden agregar más fotos
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
        
        var nombre: String {
            return self.rawValue
        }
    }
    
    
    /// Valida los datos de la donación
    func validateDonation() -> Bool {
        // Debe haber al menos 2 imágenes
        guard selectedImages.count >= 2 else {
            errorMessage = "Debes seleccionar al menos 2 fotos"
            return false
        }
        
        // El título no puede estar vacío
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "El título es requerido"
            return false
        }
        
        // Debe haber al menos 1 categoría
        guard !selectedCategories.isEmpty else {
            errorMessage = "Selecciona al menos una categoría"
            return false
        }
        
        return true
    }
    
    /// Sube la donación a Firebase
    @MainActor
    func submitDonation(userId: String, bazarId: String? = nil) async {
        guard validateDonation() else { return }
        
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        do {
            // 1. Crear la donación en Firestore (sin fotos aún)
            let donationId = try await firestoreService.createDonation(
                for: userId,
                title: title,
                description: description,
                categoryText: selectedCategories.joined(separator: ", "),
                bazarId: bazarId,
                photoUrls: [],
                needsTransportHelp: needsTransportHelp
            )
            
            // 2. Subir las imágenes a Storage
            let photoUrls = try await storageService.uploadDonationImages(
                docId: donationId,
                images: selectedImages,
                maxDimension: 1600,
                targetKB: 350
            )
            
            // 3. Actualizar la donación con las URLs de las fotos
            try await firestoreService.updateDonationPhotoURLs(
                docId: donationId,
                urls: photoUrls
            )
            
            // ✅ Éxito
            successMessage = "¡Donación subida exitosamente!"
            resetForm()
            
        } catch {
            errorMessage = "Error al subir donación: \(error.localizedDescription)"
            print("Error en submitDonation: \(error)")
        }
        
        isLoading = false
    }
    
    /// Reinicia el formulario
    private func resetForm() {
        selectedImages = []
        title = ""
        description = ""
        selectedCategories = []
        needsTransportHelp = false
    }
    
    /// Agrega o quita una categoría
    func toggleCategory(_ category: String) {
        if selectedCategories.contains(category) {
            selectedCategories.removeAll { $0 == category }
        } else {
            selectedCategories.append(category)
        }
    }
}
