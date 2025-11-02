//
//  Models.swift
//  caritas
//
//  Created by Juan Luis Alvarez Cisneros on 31/10/25.
//

import Foundation
import FirebaseFirestore

// MARK: - Bazar
struct Bazar: Identifiable, Codable {
    var id: String?
    var acceptingDonations: Bool?
    var address: String?
    var categoryIds: [String]?
    var location: String?
}

// MARK: - Donation
struct Donation: Identifiable, Codable {
    var id: String?
    var bazarId: String?
    var categoryId: [String]?
    var day: Timestamp?
    var description: String?
    var folio: String?
    var photoUrl: String?
    var status: String?           // "pending" | "approved" | "rejected"
    var title: String?
    var userId: String?

    // Helper para mapear desde Firestore sin FirebaseFirestoreSwift
    static func from(doc: DocumentSnapshot) -> Donation {
        let d = doc.data() ?? [:]
        return Donation(
            id: doc.documentID,
            bazarId: d["bazarId"] as? String,
            categoryId: d["categoryId"] as? [String],
            day: d["day"] as? Timestamp,
            description: d["description"] as? String,
            folio: d["folio"] as? String,
            photoUrl: d["photoUrl"] as? String,
            status: d["status"] as? String,
            title: d["title"] as? String,
            userId: d["userId"] as? String
        )
    }

    // Helper para escribir en Firestore
    func toDict() -> [String: Any] {
        var m: [String: Any] = [:]
        if let bazarId { m["bazarId"] = bazarId }
        if let categoryId { m["categoryId"] = categoryId }
        if let description { m["description"] = description }
        if let folio { m["folio"] = folio }
        if let photoUrl { m["photoUrl"] = photoUrl }
        if let status { m["status"] = status }
        if let title { m["title"] = title }
        if let userId { m["userId"] = userId }
        if let day { m["day"] = day }
        return m
    }
}

// MARK: - UserDoc
struct UserDoc: Identifiable, Codable {
    var id: String?
    var email: String?
    var password: String?
    var rol: String?
}
