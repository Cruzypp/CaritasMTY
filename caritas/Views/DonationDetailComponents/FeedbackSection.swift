import SwiftUI

struct FeedbackSection: View {
    let adminComment: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Feedback")
                .font(.gotham(.bold, style: .headline))
            
            Text(adminComment ?? "Sin comentarios")
                .font(.gotham(.regular, style: .body))
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(.secondary)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
        }
        .padding(.horizontal)
    }
}

#Preview {
    FeedbackSection(adminComment: "Donación en buen estado, aceptada para el bazar")
}
