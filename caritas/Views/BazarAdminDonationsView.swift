//  BazarAdminDonationsView.swift

import SwiftUI
import FirebaseFirestore   // por Timestamp.dateValue()

// Segmentos: Asignadas / Entregadas
private enum BazarDonationsSegment: String, CaseIterable, Identifiable {
    case assigned = "Asignadas"
    case delivered = "Entregadas"

    var id: String { rawValue }
}

struct BazarAdminDonationsView: View {
    @EnvironmentObject var auth: AuthViewModel
    @StateObject private var vm = BazarAdminDonationsVM()

    @State private var searchText: String = ""
    @FocusState private var searchFocused: Bool

    @State private var selectedSegment: BazarDonationsSegment = .assigned

    // Para la alerta de confirmación
    @State private var pendingDelivery: Donation?
    @State private var showConfirmAlert = false

    private let azul  = Color("azulMarino")
    private let aqua  = Color("aqua")

    // MARK: - Helpers de filtrado

    /// Donaciones asignadas (no entregadas)
    private var assignedDonations: [Donation] {
        vm.donations.filter { !($0.isDelivered ?? false) }
    }

    /// Donaciones marcadas como entregadas
    private var deliveredDonations: [Donation] {
        vm.donations.filter { $0.isDelivered ?? false }
    }

    /// Donaciones según segmento + texto buscado
    private var filteredDonations: [Donation] {
        let base: [Donation] = (selectedSegment == .assigned) ? assignedDonations : deliveredDonations

        guard !searchText.isEmpty else { return base }
        let query = searchText.lowercased()

        return base.filter { donation in
            (donation.title ?? "").lowercased().contains(query) ||
            (donation.description ?? "").lowercased().contains(query)
        }
    }

    /// Título dinámico de la pantalla
    private var screenTitle: String {
        switch selectedSegment {
        case .assigned:
            return "Donaciones asignadas"
        case .delivered:
            return "Donaciones entregadas"
        }
    }

    // MARK: - Body

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
                Text(screenTitle)
                    .font(.largeTitle.bold())
                    .foregroundStyle(azul)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top)
                    .lineLimit(1)               // ← no se parte en dos líneas
                    .minimumScaleFactor(0.7)    // ← si no cabe, reduce un poco el tamaño

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

                // Picker segmentado debajo del buscador
                Picker("", selection: $selectedSegment) {
                    ForEach(BazarDonationsSegment.allCases) { segment in
                        Text(segment.rawValue).tag(segment)
                    }
                }
                .pickerStyle(.segmented)
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
                            Text(emptyStateText)
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
                                // Swipe para marcar como entregada (solo en Asignadas)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    if selectedSegment == .assigned && !(donation.isDelivered ?? false) {
                                        Button {
                                            pendingDelivery = donation
                                            showConfirmAlert = true
                                        } label: {
                                            Label("Entregada", systemImage: "checkmark.circle.fill")
                                        }
                                        .tint(aqua)
                                    }
                                }
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
            .onDisappear {
                Task {
                    vm.stopListening()
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
        // ALERT de confirmación
        .alert("Marcar como entregada",
               isPresented: $showConfirmAlert,
               presenting: pendingDelivery) { donation in
            Button("Cancelar", role: .cancel) { }
            Button("Marcar como entregada", role: .destructive) {
                Task {
                    await vm.markAsDelivered(donation)
                }
            }
        } message: { donation in
            Text("¿Confirmas que la donación \"\(donation.title ?? "Sin título")\" fue entregada en el bazar?")
        }
    }

    // MARK: - Texto para vacíos

    private var emptyStateText: String {
        switch selectedSegment {
        case .assigned:
            return "No hay donaciones asignadas"
        case .delivered:
            return "No hay donaciones entregadas"
        }
    }
}

// MARK: - Row

private struct BazarAdminDonationRow: View {
    let donation: Donation

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Miniatura redondeada
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
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
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                } else {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

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

                // Badge "Entregada" cuando aplica
                if donation.isDelivered == true {
                    Text("Entregada")
                        .font(.caption.weight(.semibold))
                        .padding(.vertical, 3)
                        .padding(.horizontal, 8)
                        .background(
                            Capsule().fill(Color.green.opacity(0.15))
                        )
                        .foregroundColor(.green)
                }
            }

            Spacer()

          
        }
        .padding(.vertical, 6)
    }
}
