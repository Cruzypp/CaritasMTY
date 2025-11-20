//
//  QRGenerationService.swift
//  caritas
//
//  Servicio para generar códigos QR en base64 para donaciones.
//

import Foundation
import CoreImage
import UIKit

final class QRGenerationService {
    static let shared = QRGenerationService()
    private init() {}

    /// Genera un código QR basado en el ID de la donación.
    /// Retorna el código QR en formato base64 como string.
    /// - Parameter donationId: El ID único de la donación
    /// - Returns: String en formato base64 que contiene la imagen PNG del QR
    func generateQRCode(for donationId: String) -> String? {
        // Crear el contenido del QR: puede ser solo el ID o una URL completa
        let qrContent = donationId

        // Crear el filtro CIQRCodeGenerator
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }

        // Configurar los parámetros del filtro
        filter.setValue(qrContent.data(using: .utf8), forKey: "inputMessage")
        // "L", "M", "Q", "H" - Niveles de corrección de errores
        filter.setValue("M", forKey: "inputCorrectionLevel")

        // Obtener la imagen CIImage del QR
        guard let outputImage = filter.outputImage else { return nil }

        // Escalar la imagen para mejor calidad
        let scale: CGFloat = 10
        let scaledImage = outputImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        // Convertir CIImage a UIImage
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }

        // Convertir a PNG y luego a base64
        let uiImage = UIImage(cgImage: cgImage)
        guard let pngData = uiImage.pngData() else { return nil }

        return pngData.base64EncodedString()
    }
}
