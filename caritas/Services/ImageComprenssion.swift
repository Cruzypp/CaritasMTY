//
//  ImageComprenssion.swift
//  caritas
//
//  Created by Cruz Yael Pérez González on 04/11/25.
//

import UIKit
import AVFoundation
import ImageIO
import MobileCoreServices

enum CompressedPayload {
    case heic(Data), jpeg(Data)

    var data: Data {
        switch self { case .heic(let d), .jpeg(let d): return d }
    }
    var mime: String {
        switch self { case .heic: "image/heic"; case .jpeg: "image/jpeg" }
    }
    var fileExt: String {
        switch self { case .heic: "heic"; case .jpeg: "jpg" }
    }
}

func resizeImage(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
    let size = image.size
    let longest = max(size.width, size.height)
    guard longest > maxDimension else { return image }

    let scale = maxDimension / longest
    let newSize = CGSize(width: size.width * scale, height: size.height * scale)
    let renderer = UIGraphicsImageRenderer(size: newSize)
    return renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: newSize)) }
}

/// Comprime a HEIC si está disponible, si no cae a JPEG.
/// maxDimension: lado mayor (px); quality: 0…1
func compressImage(_ image: UIImage,
                   maxDimension: CGFloat = 1600,
                   quality: CGFloat = 0.7,
                   preferHEIC: Bool = true) -> CompressedPayload? {

    let resized = resizeImage(image, maxDimension: maxDimension)

    if preferHEIC,
       let cg = resized.cgImage {
        let data = NSMutableData()
        guard let dest = CGImageDestinationCreateWithData(data as CFMutableData,
                                                          AVFileType.heic.rawValue as CFString,
                                                          1, nil) else { return nil }
        let opts: [CFString: Any] = [kCGImageDestinationLossyCompressionQuality: quality]
        CGImageDestinationAddImage(dest, cg, opts as CFDictionary)
        if CGImageDestinationFinalize(dest) { return .heic(data as Data) }
    }

    if let jpeg = resized.jpegData(compressionQuality: quality) {
        return .jpeg(jpeg)
    }
    return nil
}

/// (Opcional) Fuerza un tamaño objetivo en KB ajustando calidad.
func compressToTargetKB(_ image: UIImage,
                        maxDimension: CGFloat = 1600,
                        targetKB: Int = 350,
                        preferHEIC: Bool = true) -> CompressedPayload? {
    // Búsqueda lineal descendente simple (suficiente en la práctica)
    var q: CGFloat = 0.8
    while q >= 0.3 {
        if let p = compressImage(image, maxDimension: maxDimension, quality: q, preferHEIC: preferHEIC),
           p.data.count <= targetKB * 1024 {
            return p
        }
        q -= 0.1
    }
    // si no alcanza, devuelve la mejor última
    return compressImage(image, maxDimension: maxDimension, quality: 0.3, preferHEIC: preferHEIC)
}
