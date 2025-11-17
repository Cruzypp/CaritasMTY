//
//  OptimizedAsyncImage.swift
//  caritas
//
//  Componente optimizado para carga progresiva de imágenes con efecto blur-up
//

import SwiftUI

struct OptimizedAsyncImage<Content: View>: View {
    let url: URL?
    let content: (AsyncImagePhase) -> Content
    
    @State private var blurImage: UIImage?
    @State private var fullImage: UIImage?
    
    var body: some View {
        ZStack {
            // Mostrar imagen con blur mientras carga la versión completa
            if let blurImage = blurImage {
                Image(uiImage: blurImage)
                    .resizable()
                    .scaledToFill()
                    .blur(radius: 10)
                    .transition(.opacity)
            }
            
            // AsyncImage de alta calidad
            AsyncImage(url: url, content: content)
        }
    }
}

/// Función auxiliar para crear una imagen con blur (thumbnail)
func createBlurThumbnail(from image: UIImage, maxDimension: CGFloat = 200) -> UIImage? {
    let size = image.size
    let longest = max(size.width, size.height)
    guard longest > maxDimension else { return image }
    
    let scale = maxDimension / longest
    let newSize = CGSize(width: size.width * scale, height: size.height * scale)
    let renderer = UIGraphicsImageRenderer(size: newSize)
    return renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: newSize)) }
}
