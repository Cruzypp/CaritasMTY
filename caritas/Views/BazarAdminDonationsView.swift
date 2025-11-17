//  BazarAdminDonationsView.swift

import SwiftUI
import FirebaseFirestore   // por Timestamp.dateValue()

// MARK: - Vista principal

struct BazarAdminDonationsView: View {
    @EnvironmentObject var auth: AuthViewModel
    @StateObject private var vm = BazarAdminDonationsVM()

    private let azul = Color("azulMarino")

    // Buscador
    @State private var searchText: String = ""
    @FocusState private var searchFocused: Bool

    // Donaciones filtradas por el texto de búsqueda
    private var filteredDonations: [Donation] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return vm.donations }

        let q = query.lowercased()
        return vm.donations.filter { donation in
            let title = donation.title?.lowercased() ?? ""
            let desc  = donation.description?.lowercased() ?? ""
            let folio = donation.folio?.lowercased() ?? ""
            return title.contains(q) || desc.contains(q) || folio.contains(q)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {

                // Título
                Text("Donaciones asignadas")
                    .font(.largeTitle.bold())
                    .foregroundStyle(azul)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top)

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
                            Text("Aún no hay donaciones asignadas a este bazar")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(filteredDonations, id: \.id) { donation in
                                NavigationLink {
                                    // Reutilizamos la vista de detalle del donante
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
        .task {
            guard let bazarId = auth.bazarId else {
                vm.error = "No tienes un bazar asignado."
                return
            }
            await vm.load(for: bazarId)
        }
    }
}

// MARK: - Row de cada donación

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

// MARK: - Preview

struct BazarAdminDonationsView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = AuthViewModel()
        // Fake role para ver la vista en canvas
        vm.role = "adminBazar"
        vm.bazarId = "Alameda"

        return BazarAdminDonationsView()
            .environmentObject(vm)
    }
}
