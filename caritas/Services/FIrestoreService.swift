//
//  FirestoreService.swift
//  caritas
//
//  Created by Juan Luis Alvarez Cisneros on 31/10/25.
//

import Foundation
import FirebaseFirestore

final class FirestoreService {
    static let shared = FirestoreService()
    private init() {}

    private let db = Firestore.firestore()

    // MARK: - DONOR FLOW

    /// Crea una donación para el usuario actual (puede iniciar sin fotos).
    /// Devuelve el ID del documento creado en `donations`.
    @discardableResult
    func createDonation(for uid: String,
                        title: String,
                        description: String,
                        categoryText: String,
                        bazarId: String? = nil,
                        photoUrls: [String] = [],
                        needsTransportHelp: Bool = false) async throws -> String {

        let categories = categoryText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let donation = Donation(
            id: nil,
            bazarId: bazarId,
            categoryId: categories,
            day: nil, // lo pondrá el servidor
            description: description,
            adminComment: nil,
            folio: nil,
            photoUrls: photoUrls, // arreglo (puede iniciar vacío)
            status: "pending",
            title: title,
            userId: uid,
            needsTransportHelp: needsTransportHelp
        )

        let ref = db.collection("donations").document()
        var data = donation.toDict()
        data["day"] = FieldValue.serverTimestamp() // timestamp del servidor

        try await ref.setData(data)
        return ref.documentID
    }

    /// Sobrescribe el arreglo `photoUrls` del documento con las URLs provistas.
    func updateDonationPhotoURLs(docId: String, urls: [String]) async throws {
        try await db.collection("donations")
            .document(docId)
            .setData(["photoUrls": urls], merge: true)
    }

    /// (Opcional) Agrega URLs al arreglo `photoUrls` sin borrar las existentes.
    func appendDonationPhotoURLs(docId: String, urls: [String]) async throws {
        try await db.collection("donations")
            .document(docId)
            .setData(["photoUrls": FieldValue.arrayUnion(urls)], merge: true)
    }

    /// Donaciones del usuario autenticado (ordenadas por fecha desc).
    func myDonations(for uid: String) async throws -> [Donation] {
        let snap = try await db.collection("donations")
            .whereField("userId", isEqualTo: uid)
            .order(by: "day", descending: true)
            .getDocuments()
        return snap.documents.map { Donation.from(doc: $0) }
    }

    // MARK: - BAZAR ADMIN FLOW

    /// Donaciones APROBADAS para un bazar específico (ordenadas por fecha desc).
    /// Útil para el rol `adminBazar` que necesita ver lo que llegará a su bazar.
    func approvedDonations(forBazarId bazarId: String) async throws -> [Donation] {
        let snap = try await db.collection("donations")
            .whereField("status", isEqualTo: "approved")
            .whereField("bazarId", isEqualTo: bazarId)
            .order(by: "day", descending: true)
            .getDocuments()
        return snap.documents.map { Donation.from(doc: $0) }
    }

    // MARK: - FETCH para pruebas / listas

    func fetchBazaars() async throws -> [Bazar] {
        let snap = try await db.collection("bazars").getDocuments()
        return snap.documents.map { doc in
            let d = doc.data()

            // Mapea "direccion" de Firestore a "address" del modelo
            let address = (d["address"] as? String) ?? (d["direccion"] as? String)

            // Extrae coordenadas de múltiples fuentes posibles
            var latitude: Double?
            var longitude: Double?

            // Intenta obtener de los campos directos primero
            latitude = (d["latitude"] as? Double) ?? (d["latitud"] as? Double)
            longitude = (d["longitude"] as? Double) ?? (d["longitud"] as? Double)

            // Si no están en campos directos, intenta extraer del GeoPoint "ubicacion"
            if (latitude == nil || longitude == nil),
               let geoPoint = d["ubicacion"] as? GeoPoint {
                latitude = geoPoint.latitude
                longitude = geoPoint.longitude
            }

            return Bazar(
                id: doc.documentID,
                acceptingDonations: d["acceptingDonations"] as? Bool,
                address: address,
                categoryIds: d["categoryIds"] as? [String],
                location: d["location"] as? String,
                nombre: d["nombre"] as? String,
                latitude: latitude,
                longitude: longitude,
                horarios: d["horarios"] as? String,
                telefono: d["telefono"] as? String,
                categorias: d["categorias"] as? [String: String]
            )
        }
    }

    func fetchDonations() async throws -> [Donation] {
        let snap = try await db.collection("donations")
            .order(by: "day", descending: true)
            .getDocuments()
        return snap.documents.map { Donation.from(doc: $0) }
    }

    /// Obtiene todas las donaciones y resuelve las URLs de Firebase Storage
    /// Este método es útil cuando las imágenes están guardadas en Storage pero no hay URLs en Firestore
    func fetchDonationsWithStorageURLs() async throws -> [Donation] {
        let snap = try await db.collection("donations").getDocuments()
        var donations: [Donation] = []

        for doc in snap.documents {
            var donation = Donation.from(doc: doc)

            // Si no hay photoUrls, intentar obtenerlas de Storage
            if donation.photoUrls?.isEmpty ?? true, let donationId = donation.id {
                do {
                    let storageURLs = try await StorageService.shared.getDonationImageURLs(for: donationId)
                    donation.photoUrls = storageURLs
                } catch {
                    print("No se pudieron obtener imágenes de Storage para \(donationId): \(error)")
                }
            }
            donations.append(donation)
        }

        return donations
    }

    func fetchUsers() async throws -> [UserDoc] {
        let snap = try await db.collection("users").getDocuments()
        return snap.documents.map { doc in
            let d = doc.data()
            return UserDoc(
                id: doc.documentID,
                email: d["email"] as? String,
                password: d["password"] as? String,
                // acepta tanto "role" como "rol" y también bazarId
                rol: (d["role"] as? String) ?? (d["rol"] as? String),
                bazarId: d["bazarId"] as? String
            )
        }
    }

    // MARK: - Ping (lectura 1 doc)

    func ping(documentPath: String) async throws -> [String: Any] {
        let snap = try await db.document(documentPath).getDocument()
        return snap.data() ?? [:]
    }

    // MARK: - ADMIN (CALIDAD) FLOW

    /// Donaciones con `status == "pending"`, ordenadas por `day` desc.
    func pendingDonations() async throws -> [Donation] {
        let snap = try await db.collection("donations")
            .whereField("status", isEqualTo: "pending")
            .order(by: "day", descending: true)
            .getDocuments()
        return snap.documents.map { Donation.from(doc: $0) }
    }

    /// Actualiza estatus y registra quién revisó.
    func setDonationStatus(donationId: String,
                           status: String,
                           reviewerId: String) async throws {
        try await db.collection("donations")
            .document(donationId)
            .setData([
                "status": status,
                "reviewerId": reviewerId,
                "reviewedAt": FieldValue.serverTimestamp()
            ], merge: true)
        
    }
    /// Guarda o actualiza el comentario del admin para una donación.
    func setAdminComment(donationId: String, comment: String) async throws {
        try await db.collection("donations")
            .document(donationId)
            .setData(["adminComment": comment], merge: true)
    }
    
    func fetchApprovedDonations(forBazarId bazarId: String) async throws -> [Donation] {
            let snapshot = try await db.collection("donations")
                .whereField("bazarId", isEqualTo: bazarId)
                .whereField("status", isEqualTo: "approved")
                .order(by: "day", descending: false)
                .getDocuments()

            return snapshot.documents.map { Donation.from(doc: $0) }
        }
    // MARK: - BAZAR ADMIN
    /// Actualiza si un bazar está recibiendo donaciones o no.
    func updateBazarAcceptingDonations(bazarId: String, isAccepting: Bool) async throws {
        try await db.collection("bazars")
            .document(bazarId)
            .setData(["acceptingDonations": isAccepting], merge: true)
    }

    /// Lee el campo `acceptingDonations` de un bazar (default true si no existe).
    func fetchBazarAcceptingDonations(bazarId: String) async throws -> Bool {
        let snap = try await db.collection("bazars").document(bazarId).getDocument()
        let data = snap.data() ?? [:]
        return data["acceptingDonations"] as? Bool ?? true
    }
}
