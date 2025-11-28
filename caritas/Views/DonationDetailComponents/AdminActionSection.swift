import SwiftUI

struct AdminActionSection: View {
    let isDelivered: Bool
    let donation: Donation
    let onMarkDelivered: () -> Void
    
    var body: some View {
        VStack {
            if isDelivered {
                Text("Esta donación ya fue entregada.")
                    .font(.gotham(.bold, style: .body))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal)
                
            } else {
                Button(action: onMarkDelivered) {
                    Text("Marcar como ENTREGADA")
                        .font(.gotham(.bold, style: .headline))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.aqua)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .padding(.horizontal)
                        .shadow(radius: 10)
                }
            }
        }
    }
}

#Preview {
    AdminActionSection(
        isDelivered: true,
        donation: Donation(
            id: "D001",
            title: "Test Donation",
            userId: "U001"
        ),
        onMarkDelivered: {}
    )
}
