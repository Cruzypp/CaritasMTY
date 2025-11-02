import SwiftUI

struct DonorHomeView: View {
    @EnvironmentObject var donationVM: DonationViewModel

    var body: some View {
        NavigationStack {
            List {
                // Formulario
                Section("Nueva donación") {
                    TextField("Título", text: $donationVM.title)

                    TextField("Descripción", text: $donationVM.description, axis: .vertical)
                        .lineLimit(1...4)

                    TextField("Categorías (coma separadas) ej. ropa,comida",
                              text: $donationVM.categoryText)

                    TextField("Bazar (opcional, id)", text: Binding(
                        get: { donationVM.bazarId ?? "" },
                        set: { donationVM.bazarId = $0.isEmpty ? nil : $0 }
                    ))

                    Button(donationVM.isSending ? "Enviando..." : "Enviar donación") {
                        Task { await donationVM.sendDonation() }
                    }
                    .disabled(donationVM.isSending || donationVM.title.isEmpty)
                }

                // Lista “Mis donaciones”
                Section("Mis donaciones") {
                    if donationVM.loadingMy {
                        ProgressView()
                    } else if donationVM.myDonations.isEmpty {
                        Text("Aún no tienes donaciones.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(donationVM.myDonations) { d in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(d.title ?? "—").font(.headline)
                                if let desc = d.description, !desc.isEmpty {
                                    Text(desc).font(.subheadline).foregroundStyle(.secondary)
                                }
                                HStack {
                                    Text("Estado: \(d.status ?? "—")")
                                    if let cats = d.categoryId, !cats.isEmpty {
                                        Text("• \(cats.joined(separator: ", "))")
                                    }
                                }
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }

                if let msg = donationVM.message {
                    Section("Mensaje") { Text(msg).font(.footnote) }
                }
            }
            .navigationTitle("Donaciones")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Actualizar") { Task { await donationVM.loadMyDonations() } }
                }
            }
            .task { await donationVM.loadMyDonations() }
        }
    }
}

#Preview {
    // Stubs para que el canvas no truene
    let donationVM = DonationViewModel()
    let authVM = AuthViewModel()

    return DonorHomeView()
        .environmentObject(authVM)        // si DonorHomeView usa Auth
        .environmentObject(donationVM)    // requerido por el canvas
}
