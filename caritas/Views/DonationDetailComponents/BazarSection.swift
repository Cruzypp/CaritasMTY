import SwiftUI

struct BazarSection: View {
    let isApproved: Bool
    let bazar: Bazar?
    let isLoading: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Bazar asignado")
                .font(.gotham(.bold, style: .headline))
            
            if isApproved {
                if isLoading {
                    HStack {
                        ProgressView()
                            .tint(.aqua)
                        Text("Cargando bazar...")
                            .font(.gotham(.regular, style: .body))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                } else if let bazar = bazar {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(bazar.nombre ?? "Bazar Cáritas")
                        Text(bazar.address ?? "")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                } else {
                    Text("No se pudo cargar la información del bazar.")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
            } else {
                Text("El bazar se mostrará cuando la donación sea aprobada.")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    BazarSection(
        isApproved: false,
        bazar: Bazar(
            id: "B001",
            address: "Calle Principal 123", 
            nombre: "Bazar Alameda"
        ),
        isLoading: false
    )
}
