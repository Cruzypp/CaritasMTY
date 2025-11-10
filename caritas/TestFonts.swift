import Foundation
import FirebaseFirestore

struct BazarDTO: Codable {
    let nombre: String
    let address: String
    let latitude: Double
    let longitude: Double
    let horarios: String
    let telefono: String
    let categorias: [String: String]
    
    // Para compatibilidad con JSON que usan "direccion", "latitud", "longitud"
    enum CodingKeys: String, CodingKey {
        case nombre, horarios, telefono, categorias
        case address = "direccion"
        case latitude = "latitud"
        case longitude = "longitud"
    }
}

func seedBazaresIfNeeded() async throws {
    guard let url = Bundle.main.url(forResource: "bazares", withExtension: "json") else {
        throw NSError(domain: "Seed", code: 1, userInfo: [NSLocalizedDescriptionKey: "JSON no encontrado en bundle"])
    }
    let data = try Data(contentsOf: url)
    let bazares = try JSONDecoder().decode([BazarDTO].self, from: data)

    let db = Firestore.firestore()
    let batch = db.batch()
    let col = db.collection("bazars")

    for b in bazares {
        let id = b.nombre.replacingOccurrences(of: " ", with: "_")
        let ref = col.document(id)
        batch.setData([
            "nombre": b.nombre,
            "address": b.address,
            "telefono": b.telefono,
            "horarios": b.horarios,
            "latitude": b.latitude,
            "longitude": b.longitude,
            "categorias": b.categorias
        ], forDocument: ref, merge: true)
    }

    try await batch.commit()
}
