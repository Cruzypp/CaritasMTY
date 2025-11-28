import SwiftUI
import FirebaseCore

struct InfoSection: View {
    let donation: Donation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(donation.title ?? "Sin título")
                .font(.gotham(.bold, style: .title3))
            
            Text(donation.description ?? "Sin descripción")
                .font(.gotham(.regular, style: .callout))
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            HStack {
                Text("Estado:")
                    .font(.gotham(.bold, style: .body))
                
                Spacer()
                
                Text(statusLabel(donation.status ?? "pending"))
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(statusColor(donation.status ?? "pending"))
                    .foregroundColor(.white)
                    .cornerRadius(20)
            }
        }
        .padding(.horizontal)
    }
    
    private func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "pending": return .gray
        case "approved": return .aqua
        case "rejected": return .red
        default: return .gray
        }
    }
    
    private func statusLabel(_ status: String) -> String {
        switch status.lowercased() {
        case "pending": return "PENDIENTE"
        case "approved": return "APROBADA"
        case "rejected": return "RECHAZADA"
        default: return status.uppercased()
        }
    }
}

#Preview {
    InfoSection(donation: Donation(
        id: "D001",
        bazarId: "B001",
        categoryId: ["ropa"],
        day: Timestamp(),
        description: "Test donation",
        folio: "FOL-001",
        photoUrls: [],
        status: "approved",
        title: "Test Donation",
        userId: "U001"
    ))
}
