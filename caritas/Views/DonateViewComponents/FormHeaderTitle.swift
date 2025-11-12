import SwiftUI

struct FormHeaderTitle: View {
    var body: some View {
        Text("CREAR DONACIÓN")
            .font(.gotham(.bold, style: .title))
            .foregroundColor(.azulMarino)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 20)
    }
}
