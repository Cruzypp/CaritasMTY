import Foundation
import FirebaseFirestore

struct BazarDTO: Codable {
    let nombre: String
    let direccion: String
    let latitud: Double
    let longitud: Double
    let horarios: String
    let telefono: String
    let categorias: [String: String]
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
            "direccion": b.direccion,
            "telefono": b.telefono,
            "horarios": b.horarios,
            // Guarda GeoPoint como diccionario {lat, lng} o usa GeoPoint con FieldValue:
            "ubicacion": GeoPoint(latitude: b.latitud, longitude: b.longitud),
            "categorias": b.categorias
        ], forDocument: ref, merge: true)
    }

    try await batch.commit()
}
