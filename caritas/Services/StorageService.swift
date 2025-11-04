//
//  StorageService.swift
//  caritas
//
//  Created by Juan Luis Alvarez Cisneros on 31/10/25.
//

import Foundation
import FirebaseStorage
import UIKit

final class StorageService {
    static let shared = StorageService()
    private init() {}

    private let storage = Storage.storage()

    // Sube imágenes a: donations/{docId}/{filename}.jpg y devuelve URLs públicas.
    func uploadDonationImages(docId: String, images: [UIImage]) async throws -> [String] {
        guard !images.isEmpty else { return [] }

        let folderRef = storage.reference(withPath: "donations/\(docId)")
        var urls: [String] = []

        for (idx, image) in images.enumerated() {
            // 1) Data + metadata
            guard let data = image.jpegData(compressionQuality: 0.85) else { continue }
            let meta = StorageMetadata()
            meta.contentType = "image/jpeg"

            // 2) Nombre ÚNICO para evitar colisiones y facilitar caché/CDN
            let unique = UUID().uuidString.prefix(8)
            let filename = "img_\(idx)_\(unique).jpg"
            let fileRef = folderRef.child(filename)

            // 3) Subir
            _ = try await fileRef.putDataAsync(data, metadata: meta)

            // 4) Obtener URL con pequeño retry (por si la CDN tarda un instante)
            let url = try await retry(times: 5, delay: 0.4) {
                try await fileRef.downloadURL()
            }
            urls.append(url.absoluteString)
        }

        return urls
    }
}

// MARK: - Helpers
private extension StorageService {
    // putData con async/await (evita usar closure + semaphore)
    func putDataAsync(_ ref: StorageReference, data: Data, metadata: StorageMetadata?) async throws -> StorageMetadata {
        try await withCheckedThrowingContinuation { cont in
            ref.putData(data, metadata: metadata) { meta, err in
                if let err = err { cont.resume(throwing: err) }
                else { cont.resume(returning: meta ?? StorageMetadata()) }
            }
        }
    }
}

private func retry<T>(times: Int, delay: TimeInterval, _ block: @escaping () async throws -> T) async throws -> T {
    var lastError: Error?
    for attempt in 0..<times {
        do { return try await block() }
        catch {
            lastError = error
            if attempt < times - 1 { try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000)) }
        }
    }
    throw lastError!
}
