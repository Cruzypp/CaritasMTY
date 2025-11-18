//  BazarAdminDonationsView.swift

import SwiftUI
import FirebaseFirestore   // por Timestamp.dateValue()

struct BazarAdminDonationsView: View {
    @EnvironmentObject var auth: AuthViewModel
    @StateObject private var vm = BazarAdminDonationsVM()

    @State private var searchText: String = ""
    @FocusState private var searchFocused: Bool

    private let azul = Color("azulMarino")

    // Filtro por texto
    private var filteredDonations: [Donation] {
        guard !searchText.isEmpty else { return vm.donations }
        let query = searchText.lowercased()
        return vm.donations.filter { donation in
            (donation.title ?? "").lowercased().contains(query) ||
            (donation.description ?? "").lowercased().contains(query)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {

                // 🔥 Banner si el bazar NO está aceptando donaciones
                if vm.isAcceptingDonations == false {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.title3)
                            .foregroundColor(.orange)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Este bazar no está aceptando donaciones")
                                .font(.gotham(.bold, style: .body))

                            Text("Mientras esta opción esté desactivada, los donantes no podrán seleccionar este bazar al crear nuevas donaciones.")
                                .font(.gotham(.regular, style: .caption))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.orange.opacity(0.15))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                // Título
                Text("Donaciones asignadas")
                    .font(.largeTitle.bold())
                    .foregroundStyle(azul)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                // Buscador
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Buscar donación…", text: $searchText)
                        .font(.gotham(.regular, style: .body))
                        .textFieldStyle(.plain)
                        .autocorrectionDisabled()
                        .focused($searchFocused)
                        .submitLabel(.search)
                        .onSubmit { searchFocused = false }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)

                Group {
                    if vm.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    } else if let err = vm.error {
                        VStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.title2)
                                .foregroundStyle(.red)
                            Text("Error al cargar donaciones")
                                .font(.headline)
                            Text(err)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if filteredDonations.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "tray")
                                .font(.title2)
                                .foregroundStyle(.secondary)
                            Text("No hay donaciones aprobadas")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(filteredDonations, id: \.id) { donation in
                                NavigationLink {
                                    DonationDetailView(donation: donation)
                                } label: {
                                    BazarAdminDonationRow(donation: donation)
                                }
                                .buttonStyle(.plain)
                                .listRowSeparator(.hidden)
                            }
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            // ⚠️ Muy importante: recargar cada vez que regresamos de Configuración
            .onAppear {
                Task {
                    if let bazarId = auth.bazarId {
                        await vm.load(for: bazarId)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        BazarAdminSettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.title2.bold())
                            .foregroundStyle(.gray)
                    }
                }
            }
        }
        // Carga inicial (por si la vista aparece por primera vez)
        .task {
            if let bazarId = auth.bazarId {
                await vm.load(for: bazarId)
            }
        }
    }
}

// Row sencilla para cada donación (igual que ya la tenías)
private struct BazarAdminDonationRow: View {
    let donation: Donation

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Miniatura
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(.systemGray6))

                if let first = donation.photoUrls?.first,
                   let url = URL(string: first) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        case .empty:
                            ProgressView()
                        case .failure:
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        @unknown default:
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                } else {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 56, height: 56)
            .clipped()

            // Texto
            VStack(alignment: .leading, spacing: 6) {
                Text(donation.title ?? "Sin título")
                    .font(.headline)

                if let desc = donation.description, !desc.isEmpty {
                    Text(desc)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                if let ts = donation.day {
                    let date = ts.dateValue()
                    Text(date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }
}
