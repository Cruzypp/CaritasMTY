//
//  CameraView.swift
//  caritas
//
//  Created by Cruz Yael Pérez González on 12/11/25.
//

import Foundation
import SwiftUI
import UIKit

// Controlador de UIKit a SwiftUI -> UIViewControllerRepresentable
struct CameraView: UIViewControllerRepresentable {
    @Binding var images: [UIImage] // Se guardan las fotos en un array de variables
    @Environment(\.presentationMode) var presentationMode
    
    // Límite máximo de fotos permitidas (viene del ViewModel)
    let maxPhotos: Int
    
    // Calcula cuántas fotos más se pueden tomar
    var remainingPhotos: Int {
        max(0, maxPhotos - images.count)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController() // Picker de fotos
        picker.delegate = context.coordinator // el coordinador sirve como intermediario para saber qué hace el usuario
        picker.sourceType = .camera // Aquí se indica que se usará la cámara y no el carrete de fotos
        
        // Verifica si se alcanzó el límite de fotos
        if remainingPhotos == 0 {
            // Aquí podrías mostrar un error antes de abrir la cámara
            presentationMode.wrappedValue.dismiss()
        }
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // SwiftUI no puede recibir directamente los eventos del UIImagePickerController
    // por eso se necesita este puente (delegate).
    
    // UIImagePickerControllerDelegate: para detectar cuando el usuario toma una foto o cancela.
    
    // UINavigationControllerDelegate: requerido por el picker.
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                // Solo agrega la foto si no hemos alcanzado el límite
                if parent.images.count < parent.maxPhotos {
                    parent.images.append(image)
                }
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
