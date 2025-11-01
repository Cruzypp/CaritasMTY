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

    // Colecciones
    func fetchBazaars() async throws -> [Bazar] {
        let snap = try await db.collection("bazars").getDocuments()
        return snap.documents.compactMap { try? $0.data(as: Bazar.self) }
    }

    func fetchDonations() async throws -> [Donation] {
        let snap = try await db.collection("donations").getDocuments()
        return snap.documents.compactMap { try? $0.data(as: Donation.self) }
    }

    func fetchUsers() async throws -> [UserDoc] {
        let snap = try await db.collection("users").getDocuments()
        return snap.documents.compactMap { try? $0.data(as: UserDoc.self) }
    }

    // Leer un documento específico (para probar)
    func ping(documentPath: String) async throws -> [String: Any] {
        let ref = db.document(documentPath) // ej. "donations/don_001"
        let snap = try await ref.getDocument()
        return snap.data() ?? [:]
    }
}
