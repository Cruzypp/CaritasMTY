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

    /// Sube imágenes (las comprime antes). Devuelve URLs descargables.
    func uploadDonationImages(docId: String,
                              images: [UIImage],
                              maxDimension: CGFloat = 1600,
                              targetKB: Int? = nil) async throws -> [String] {

        guard !images.isEmpty else { return [] }
        var urls: [String] = []
        let baseRef = Storage.storage().reference().child("donations/\(docId)")

        for (idx, img) in images.enumerated() {
            // 1) Comprimir
            let payload: CompressedPayload?
            if let targetKB {
                payload = compressToTargetKB(img, maxDimension: maxDimension, targetKB: targetKB)
            } else {
                payload = compressImage(img, maxDimension: maxDimension, quality: 0.7, preferHEIC: true)
            }
            guard let payload else { throw NSError(domain: "Compress", code: -1,
                                                   userInfo: [NSLocalizedDescriptionKey: "No se pudo comprimir la imagen \(idx)"]) }

            // 2) Path y metadata
            let filename = "photo_\(idx).\(payload.fileExt)"
            let ref = baseRef.child(filename)

            let meta = StorageMetadata()
            meta.contentType = payload.mime

            // 3) Subir (async)
            _ = try await ref.putDataAsync(payload.data, metadata: meta)

            // 4) Obtener URL
            let url = try await ref.downloadURL()
            urls.append(url.absoluteString)
        }
        return urls
    }
    
    /// Obtiene la URL de descarga de una imagen en Firebase Storage
    /// - Parameters:
    ///   - path: Ruta completa en storage (ej: "donations/docId/photo_0.heic")
    /// - Returns: URL string para descargar la imagen
    func getDownloadURL(for path: String) async throws -> String {
        let ref = Storage.storage().reference().child(path)
        let url = try await ref.downloadURL()
        return url.absoluteString
    }
    
    /// Obtiene URLs de todas las imágenes de una donación
    /// - Parameter docId: ID de la donación
    /// - Returns: Array de URLs descargables
    func getDonationImageURLs(for docId: String) async throws -> [String] {
        let baseRef = Storage.storage().reference().child("donations/\(docId)")
        let result = try await baseRef.listAll()
        
        var urls: [String] = []
        for item in result.items.sorted(by: { $0.name < $1.name }) {
            let url = try await item.downloadURL()
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
