//
//  Models.swift
//  caritas
//
//  Created by Juan Luis Alvarez Cisneros on 31/10/25.
//

import Foundation
import FirebaseFirestore

struct Bazar: Identifiable, Codable {
    @DocumentID var id: String?
    var acceptingDonations: Bool?
    var address: String?
    var categoryIds: [String]?
    // En tus dummies parece ser string; si luego lo migras a GeoPoint, cambia el tipo.
    var location: String?
}

struct Donation: Identifiable, Codable {
    @DocumentID var id: String?
    var bazarId: String?
    var categoryId: [String]?
    var day: Timestamp?
    var description: String?
    var folio: String?
    var photoUrl: String?
    var status: String?
    var title: String?
    var userId: String?
}

struct UserDoc: Identifiable, Codable {
    @DocumentID var id: String?
    var email: String?
    var password: String?
    var rol: String?
}
