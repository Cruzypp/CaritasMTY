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

    /// Crea una donación para el usuario actual
    func createDonation(for uid: String,
                        title: String,
                        description: String,
                        categoryText: String,
                        bazarId: String? = nil) async throws -> String {

        let categories = categoryText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let donation = Donation(
            id: nil,
            bazarId: bazarId,
            categoryId: categories,
            day: nil, // lo pondrá el server
            description: description,
            folio: nil,
            photoUrl: nil,
            status: "pending",
            title: title,
            userId: uid
        )

        let ref = db.collection("donations").document()
        var data = donation.toDict()
        data["day"] = FieldValue.serverTimestamp()

        try await ref.setData(data)
        return ref.documentID
    }

    /// Donaciones del usuario autenticado (descendentes por fecha)
    func myDonations(for uid: String) async throws -> [Donation] {
        let snap = try await db.collection("donations")
            .whereField("userId", isEqualTo: uid)
            .order(by: "day", descending: true)
            .getDocuments()

        return snap.documents.map { Donation.from(doc: $0) }
    }

    // MARK: - FETCH para pruebas / listas

    func fetchBazaars() async throws -> [Bazar] {
        let snap = try await db.collection("bazars").getDocuments()
        return snap.documents.map { doc in
            // Simple mapeo manual usando Codable por clave
            let d = doc.data()
            return Bazar(
                id: doc.documentID,
                acceptingDonations: d["acceptingDonations"] as? Bool,
                address: d["address"] as? String,
                categoryIds: d["categoryIds"] as? [String],
                location: d["location"] as? String
            )
        }
    }

    func fetchDonations() async throws -> [Donation] {
        let snap = try await db.collection("donations").getDocuments()
        return snap.documents.map { Donation.from(doc: $0) }
    }

    func fetchUsers() async throws -> [UserDoc] {
        let snap = try await db.collection("users").getDocuments()
        return snap.documents.map { doc in
            let d = doc.data()
            return UserDoc(
                id: doc.documentID,
                email: d["email"] as? String,
                password: d["password"] as? String,
                rol: d["rol"] as? String
            )
        }
    }

    // MARK: - Ping (lectura 1 doc)

    func ping(documentPath: String) async throws -> [String: Any] {
        let snap = try await db.document(documentPath).getDocument()
        return snap.data() ?? [:]
    }

    // MARK: - STUBS ADMIN (para que compile)
    func pendingDonations() async throws -> [Donation] { [] }

    func setDonationStatus(donationId: String, status: String, reviewerId: String) async throws {
        // más adelante implementamos
    }
}
