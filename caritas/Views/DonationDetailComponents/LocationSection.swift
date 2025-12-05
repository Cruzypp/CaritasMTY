import SwiftUI

struct LocationSection: View {
    let isApproved: Bool
    let bazar: Bazar?
    
    var body: some View {
        Group {
            if isApproved,
               let bazar = bazar,
               let lat = bazar.latitude,
               let lon = bazar.longitude {
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ubicación")
                        .font(.gotham(.bold, style: .headline))
                    
                    VStack {
                        NavigationLink {
                            FullMapComponent(
                                nombre: bazar.nombre ?? "",
                                lat: lat,
                                lon: lon
                            )
                        } label: {
                            MapComponent(
                                nombre: bazar.nombre ?? "",
                                lat: lat,
                                lon: lon,
                                address: bazar.address ?? ""
                            )
                        }
                    }
                }
            } else if isApproved {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ubicación")
                        .font(.gotham(.bold, style: .headline))
                    
                    Text("Ubicación no disponible.")
                        .font(.gotham(.regular, style: .body))
                        .foregroundColor(.secondary)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
            }
        }
    }
}

#Preview {
    LocationSection(
        isApproved: true,
        bazar: Bazar(
            id: "B001",
            nombre: "Bazar Alameda",
            latitude: 25.6866,
            longitude: -100.3161
        )
    )
}
