import SwiftUI

enum Status: String, CaseIterable {
    case pendiente = "Pendiente"
    case rechazado = "Rechazado"
    case aprobado  = "Aprobado"
}

struct StatusCard: View {
    let donation: Donation

    var body: some View {
        GroupBox {
            HStack(spacing: 16) {
                if let firstPhotoUrl = donation.photoUrls?.first,
                   let url = URL(string: firstPhotoUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(.rect(cornerRadius: 15))
                        case .failure(_):
                            Image(.logotipo)
                                .resizable()
                                .frame(width: 100, height: 100)
                                .clipShape(.rect(cornerRadius: 15))
                        case .empty:
                            ProgressView()
                                .frame(width: 100, height: 100)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image(.logotipo)
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(.rect(cornerRadius: 15))
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text(donation.folio ?? "")
                        .font(.gotham(.bold, style: .headline))
                        .frame(maxWidth: 200, alignment: .center)
                        .padding(5)
                        .background(Color.naranja)
                        .foregroundStyle(.white)
                        .clipShape(.rect(cornerRadius: 8))

                    Text(statusLabel(status: donation.status ?? "pending"))
                        .font(.gotham(.bold, style: .title3))
                        .frame(height: 40)
                        .frame(maxWidth: 200, alignment: .center)
                        .padding(5)
                        .background(colorEstado(status: donation.status ?? "pending"))
                        .foregroundStyle(.white)
                        .clipShape(.rect(cornerRadius: 8))
                }
            }
            .shadow(radius: 2)
        }
    }

    func colorEstado(status: String) -> Color {
        switch status.lowercased() {
        case "pending": return .gray
        case "rejected": return .red
        case "approved": return .aqua
        default: return .gray
        }
    }

    func statusLabel(status: String) -> String {
        switch status.lowercased() {
        case "pending": return "PENDIENTE"
        case "approved": return "APROBADA"
        case "rejected": return "RECHAZADA"
        default: return status.uppercased()
        }
    }
}

#Preview {
    let testDonation = Donation(
        id: "D001",
        bazarId: "B001",
        categoryId: ["ropa"],
        day: nil,
        description: "Test",
        folio: "FOL-001",
        photoUrls: ["https://firebasestorage.googleapis.com/v0/b/lostemplariosbackend.firebasestorage.app/o/donations%2FbZSA5wOLJFRo5J2skLKU%2Fphoto_0.heic?alt=media&token=8b5cf846-9cb7-4669-ba7d-853e42a59ee3"],
        status: "rejected",
        title: "Test Donation",
        userId: "U001"
    )
    StatusCard(donation: testDonation)
}
