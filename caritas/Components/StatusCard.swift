import SwiftUI
import FirebaseCore

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
                                .frame(width: 120, height: 120)
                                .clipShape(.rect(cornerRadius: 15))
                        case .failure(_):
                            Image(.logotipo)
                                .resizable()
                                .frame(width: 120, height: 120)
                                .clipShape(.rect(cornerRadius: 15))
                        case .empty:
                            ProgressView()
                                .frame(width: 120, height: 120)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image(.logotipo)
                        .resizable()
                        .frame(width: 120, height: 120)
                        .clipShape(.rect(cornerRadius: 15))
                }

                VStack(alignment: .leading, spacing: 10) {
                    
                    Text(donation.title ?? "Sin título")
                        .font(.gotham(.bold, style: .headline))
                        .lineLimit(2)
                        .foregroundStyle(.azulMarino)
                    
                    Divider()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundStyle(Color(.systemGray4))
                    
                    HStack{
                        
                        if let day = donation.day?.dateValue() {
                            Text(formatDate(day))
                                .font(.gotham(.bold, style: .footnote))
                                .foregroundStyle(.azulMarino)
                                .padding(.top, 2)
                            
                        }
                        
                        Spacer()
                        
                        Text(statusLabel(status: getDisplayStatus()))
                            .font(.gotham(.bold, style: .caption))
                            .frame(height: 20)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .frame(width: 80)
                            .padding(5)
                            .background(colorEstado(status: getDisplayStatus()))
                            .foregroundStyle(.white)
                            .clipShape(.rect(cornerRadius: 15))
                    }
    
            
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(.white)
                    .clipShape(.rect(cornerRadius: 8))
                    .foregroundColor(.black)
            }
            .shadow(color: .white.mix(with: .black, by: 0.2), radius: 2)
        }
    }

    func colorEstado(status: String) -> Color {
        switch status.lowercased() {
        case "pending": return .gray
        case "rejected": return .red
        case "approved": return .aqua
        case "delivered": return .green
        default: return .gray
        }
    }

    func statusLabel(status: String) -> String {
        switch status.lowercased() {
        case "pending": return "Pendiente"
        case "approved": return "Aprobada"
        case "rejected": return "Rechazada"
        case "delivered": return "Entregado"
        default: return status.uppercased()
        }
    }
    
    func getDisplayStatus() -> String {
        if donation.isDelivered == true {
            return "delivered"
        }
        return donation.status ?? "pending"
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "d MMM yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    let testDonation = Donation(
        id: "D001",
        bazarId: "B001",
        categoryId: ["ropa"],
        day: Timestamp(),
        description: "Test",
        folio: "FOL-001",
        photoUrls: ["https://firebasestorage.googleapis.com/v0/b/lostemplariosbackend.firebasestorage.app/o/donations%2FbZSA5wOLJFRo5J2skLKU%2Fphoto_0.heic?alt=media&token=8b5cf846-9cb7-4669-ba7d-853e42a59ee3"],
        status: "rejected",
        title: "Donacion jejejejeje",
        userId: "U001",
        isDelivered: true,
    )
    StatusCard(donation: testDonation)
}
