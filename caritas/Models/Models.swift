//
//  Models.swift
//  caritas
//
//  Created by Juan Luis Alvarez Cisneros on 31/10/25.
//

import Foundation
import FirebaseFirestore

// MARK: - Bazar
struct Bazar: Identifiable, Codable, Equatable {
    var id: String?
    var acceptingDonations: Bool?
    var address: String?
    var categoryIds: [String]?
    var location: String?
    var nombre: String?
    var latitude: Double?
    var longitude: Double?
    var horarios: String?
    var telefono: String?
    var categorias: [String: String]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case acceptingDonations
        case categoryIds
        case location
        case nombre
        case horarios
        case telefono
        case categorias
        case address
        // Mapea los nombres antiguos en español a los nuevos en inglés
        case latitude
        case longitude
    }
}

// MARK: - Bazar con Imágenes
struct BazarUI: Identifiable, Codable, Equatable {
    var id: String?
    var address: String?
    var horario: String?
    var categoryIds: [String]?
    var location: String?
    var imageUrl: String?
    var nombre: String?
    var latitude: Double?
    var longitude: Double?
    var telefono: String?
    var categorias: [String: String]?
}

// MARK: - Donation
/// Modelo compatible con Firestore (sin FirebaseFirestoreSwift).
/// - Soporta 1 o varias fotos:
///   - Lee `photoUrl` (string) o `photoUrls` ([string]).
///   - Escribe:
///       * `photoUrl` si hay 1 foto
///       * `photoUrls` si hay 2 o más
struct Donation: Identifiable, Codable, Equatable, Hashable {
    var id: String?
    var bazarId: String?
    var categoryId: [String]?
    var day: Timestamp?
    var description: String?
    var adminComment: String?      // Comentario del admin para el donante
    var folio: String?
    /// Preferencia por múltiples fotos; si sólo hay una, igual funciona.
    var photoUrls: [String]?
    var status: String?            // "pending" | "approved" | "rejected"
    var title: String?
    var userId: String?
    var needsTransportHelp: Bool?   // ¿Necesita ayuda con el traslado?
    var isDelivered: Bool?          // ✅ nueva bandera de entrega
    var qrCode: String?             // 🔲 QR generado (base64 o URL)
    var qrGeneratedAt: Timestamp?   // 🔲 Fecha de generación del QR

    // Conveniencias
    var createdAtDate: Date? { day?.dateValue() }
    var hasImages: Bool { !(photoUrls ?? []).isEmpty }
    var firstPhotoURL: URL? {
        guard let s = photoUrls?.first else { return nil }
        return URL(string: s)
    }

    // MARK: Firestore <-> Modelo (sin FirebaseFirestoreSwift)

    /// Crea Donation a partir de un DocumentSnapshot
    static func from(doc: DocumentSnapshot) -> Donation {
        let d = doc.data() ?? [:]

        // Compatibilidad: aceptar photoUrl (string) o photoUrls ([string])
        let onePhoto = d["photoUrl"] as? String
        let manyPhotos = d["photoUrls"] as? [String]
        let photos: [String]? = {
            if let arr = manyPhotos { return arr }
            if let one = onePhoto { return [one] }
            return nil
        }()

        return Donation(
            id: doc.documentID,
            bazarId: d["bazarId"] as? String,
            categoryId: d["categoryId"] as? [String],
            day: d["day"] as? Timestamp,
            description: d["description"] as? String,
            adminComment: (d["adminComment"] as? String) ?? (d["admin_comment"] as? String),
            folio: d["folio"] as? String,
            photoUrls: photos,
            status: d["status"] as? String,
            title: d["title"] as? String,
            userId: d["userId"] as? String,
            needsTransportHelp: d["needsTransportHelp"] as? Bool,
            isDelivered: d["isDelivered"] as? Bool,          // ✅ leer bandera desde Firestore
            qrCode: d["qrCode"] as? String,                 // 🔲 leer QR desde Firestore
            qrGeneratedAt: d["qrGeneratedAt"] as? Timestamp  // 🔲 leer fecha de generación
        )
    }

    /// Mapa para escribir en Firestore (usa el contrato de compatibilidad)
    func toDict() -> [String: Any] {
        var m: [String: Any] = [:]
        if let bazarId { m["bazarId"] = bazarId }
        if let categoryId { m["categoryId"] = categoryId }
        if let description { m["description"] = description }
        if let adminComment { m["adminComment"] = adminComment }   // ← escribe el comentario del admin
        if let folio { m["folio"] = folio }
        if let status { m["status"] = status }
        if let title { m["title"] = title }
        if let userId { m["userId"] = userId }
        if let day { m["day"] = day }
        if let needsTransportHelp { m["needsTransportHelp"] = needsTransportHelp }
        if let isDelivered { m["isDelivered"] = isDelivered }       // ✅ escribir bandera de entrega
        if let qrCode { m["qrCode"] = qrCode }                      // 🔲 escribir QR
        if let qrGeneratedAt { m["qrGeneratedAt"] = qrGeneratedAt } // 🔲 escribir fecha de generación

        // Escribir 1 o N fotos
        if let photos = photoUrls, !photos.isEmpty {
            if photos.count == 1 {
                m["photoUrl"] = photos.first!
            } else {
                m["photoUrls"] = photos
            }
        }

        return m
    }

    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        // Use a stable, unique identifier for hashing
        hasher.combine(id)
    }

    // Optional: ensure Equatable aligns with Hashable semantics (by id)
    static func == (lhs: Donation, rhs: Donation) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - UserDoc
struct UserDoc: Identifiable, Codable, Equatable {
    var id: String?
    var email: String?
    var password: String?
    var rol: String?
    var bazarId: String?
}
