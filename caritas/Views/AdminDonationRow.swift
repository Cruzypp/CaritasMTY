//
//  AdminDonationRow.swift
//  caritas
//
//  Created by You on 18/11/25.
//

import SwiftUI
import FirebaseFirestore

// MARK: - Donation Row (thumbnail, title, description, status, date)
struct AdminDonationRow: View {
    let donation: Donation

    init(donation: Donation) {
        self.donation = donation
    }

    public var body: some View {
        VStack(alignment: .center, spacing: 12) {
            // Thumbnail
            VStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6))

                if let first = donation.photoUrls?.first,
                   let url = URL(string: first) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 150)
                                .frame(width: 350)
                                .clipped()
                        case .empty:
                            ProgressView()
                        default:
                            Image(systemName: "photo.on.rectangle.angled")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    Image(systemName: "photo.on.rectangle.angled")
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 350, height: 150)
            
            VStack(alignment: .leading){
                HStack(){
                    Text(donation.title ?? "—")
                        .font(.gotham(.bold, style: .headline))
                    
                    Spacer()
                    
                    StatusBadge(status: donation.status ?? "pending")
                }
                .padding(.top, -15)
                
                if let ts = donation.day {
                    Text(ts.dateValue().formatted(date: .abbreviated, time: .omitted))
                        .font(.gotham(.bold, style: .caption))
                        .foregroundStyle(.secondary)
                }
                
                HStack{
                    if let desc = donation.description, !desc.isEmpty {
                        Text(desc)
                            .font(.gotham(.regular, style: .caption))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Spacer()
                    Image(systemName: "arrow.right")
                }
                .padding(.top, 2)
            }
            .padding()
        }
    }
}

// MARK: - Status Badge
private struct StatusBadge: View {
    let status: String
    var config: (text: String, color: Color) {
        switch status.lowercased() {
        case "approved": return ("Aprobada", .green.opacity(0.15))
        case "rejected": return ("Rechazada", .red.opacity(0.15))
        default:         return ("Pendiente", .orange.opacity(0.15))
        }
    }
    var body: some View {
        Text(config.text)
            .font(.caption.weight(.semibold))
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(Capsule().fill(config.color))
    }
}

#Preview {
    let donation = Donation(
        id: "D-001",
        bazarId: "Alameda",
        categoryId: ["Ropa"],
        day: Timestamp(date: Date()),
        description: "Descripción de ejemplo para ropa de invierno.",
        adminComment: nil,
        folio: "FOL-D-001",
        photoUrls: ["https://picsum.photos/seed/row/200/200"],
        status: "pending",
        title: "Ropa de invierno",
        userId: "U-1",
        needsTransportHelp: false
    )
    return AdminDonationRow(donation: donation)
        .padding()
}
