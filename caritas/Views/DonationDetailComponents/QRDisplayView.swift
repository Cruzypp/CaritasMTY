//
//  QRDisplayView.swift
//  caritas
//
//  Vista para mostrar el código QR de una donación aprobada.
//

import SwiftUI

struct QRDisplayView: View {
    let qrCodeBase64: String
    let donationId: String
    let folioNumber: String?

    @State private var showCopyConfirmation = false

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            // Título
            Text("Código QR de tu donación")
                .font(.gotham(.bold, style: .headline))
                .foregroundColor(.azulMarino)

            // Instrucciones
            Text("Muestra este código al entregar tu donación en el bazar. El administrador lo escaneará para confirmar la entrega.")
                .font(.gotham(.regular, style: .caption))
                .foregroundColor(.secondary)
                .lineLimit(3)

            Divider()
                .padding(.vertical, 8)

            // Imagen del QR
            if let imageData = Data(base64Encoded: qrCodeBase64),
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 4)
            } else {
                ZStack {
                    Color(.systemGray6)
                    Text("Error al cargar QR")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(height: 200)
                .cornerRadius(12)
            }

            // ID de la donación (folio)
            if let folio = folioNumber {
                VStack(alignment: .center, spacing: 4) {
                    Text("Folio:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(folio)
                        .font(.gotham(.bold, style: .caption))
                        .foregroundColor(.azulMarino)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }

            // Botón copiar folio
            Button(action: {
                UIPasteboard.general.string = folioNumber ?? donationId
                showCopyConfirmation = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    showCopyConfirmation = false
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "doc.on.doc")
                    Text(showCopyConfirmation ? "¡Copiado!" : "Copiar folio")
                }
                .font(.gotham(.bold, style: .body))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.aqua)
                .cornerRadius(10)
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Preview

#Preview {
    VStack {
        QRDisplayView(
            qrCodeBase64: "",
            donationId: "D-12345",
            folioNumber: "FOL-2024-001"
        )
        Spacer()
    }
    .padding()
    .background(Color.white)
}
