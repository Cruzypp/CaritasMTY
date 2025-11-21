//
//  AdminReviewsView.swift
//  caritas
//
//  Created by Juan Luis Alvarez Cisneros on 05/11/25.
//

import SwiftUI
import Combine
import FirebaseFirestore

// MARK: - Helper struct para mantener el documentID (De Main)
struct DonationWithId: Identifiable, Hashable {
    let donation: Donation
    let documentId: String
    
    var uniqueId: String {
        donation.id ?? documentId
    }
    var id: String { uniqueId }
    
    // Hashable / Equatable basados en uniqueId
    static func == (lhs: DonationWithId, rhs: DonationWithId) -> Bool {
        lhs.uniqueId == rhs.uniqueId
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(uniqueId)
    }
}

struct AdminReviewsView: View {
    @EnvironmentObject var auth: AuthViewModel
    @StateObject private var vm = AdminReviewsVM()

    enum Filter: String, CaseIterable, Identifiable, Hashable {
        case all      = "Todas"
        case pending  = "Pendientes"
        case approved = "Aprobadas"
        case rejected = "Rechazadas"
        case delivered = "Entregadas"

        var id: String { rawValue }
    }

    @State private var selection: Filter = .all
    @State private var showSettings = false      // sheet de Configuración

    var body: some View {
        TabView(selection: $selection) {
            ReviewsScreen(filter: Filter.all,
                          vm: vm,
                          showSettings: $showSettings)
                .tabItem { Label("Todas", systemImage: "tray") }
                .tag(Filter.all)

            ReviewsScreen(filter: Filter.pending,
                          vm: vm,
                          showSettings: $showSettings)
                .tabItem { Label("Pendientes", systemImage: "clock.badge.exclamationmark") }
                .tag(Filter.pending)

            ReviewsScreen(filter: Filter.approved,
                          vm: vm,
                          showSettings: $showSettings)
                .tabItem { Label("Aprobadas", systemImage: "checkmark.seal") }
                .tag(Filter.approved)

            ReviewsScreen(filter: Filter.rejected,
                          vm: vm,
                          showSettings: $showSettings)
                .tabItem { Label("Rechazadas", systemImage: "xmark.seal") }
                .tag(Filter.rejected)
            
            ReviewsScreen(filter: .delivered,
                            vm: vm,
                            showSettings: $showSettings)
                .tabItem { Label("Entregadas", systemImage: "checkmark.circle") }
                .tag(Filter.delivered)
        }
        // Se prioriza el initialize() asíncrono de Main
        .task {
            await vm.initialize()
        }
        // Configuración como SHEET a pantalla completa
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                AdminSettingsView()
                    .environmentObject(auth)
            }
        }
        // Detener listeners al salir (De Main)
        .onDisappear {
            Task {
                vm.stopListening()
            }
        }
    }
}

// MARK: - Pantalla filtrada
struct ReviewsScreen: View {
    let filter: AdminReviewsView.Filter
    @ObservedObject var vm: AdminReviewsVM
    @EnvironmentObject var auth: AuthViewModel

    @Binding var showSettings: Bool

    // Estado para navegación programática (De Main)
    @State private var selected: DonationWithId?
    
    // Variable de color (Restaurada de Sprint 1, movida localmente)
    private let azul = Color("azulMarino")

    var body: some View {
        // Lógica de filtrado usando DonationWithId (De Main)
        let filtered: [DonationWithId] = {
            let allDonations = vm.donations
            let statusFiltered: [DonationWithId]
            
            switch filter {
            case .all:
                statusFiltered = allDonations
            case .pending:
                statusFiltered = allDonations.filter { ($0.donation.status ?? "pending").lowercased() == "pending" }
            case .approved:
                statusFiltered = allDonations.filter { ($0.donation.status ?? "").lowercased() == "approved" }
            case .rejected:
                statusFiltered = allDonations.filter { ($0.donation.status ?? "").lowercased() == "rejected" }
            case .delivered:
                statusFiltered = allDonations.filter { $0.donation.isDelivered == true }
            }
            
            return statusFiltered
        }()

        return NavigationStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Revisiones")
                    .font(.largeTitle.bold())
                    .foregroundStyle(azul)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top)

                Group {
                    if vm.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)

                    } else if let err = vm.errorMessage {
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

                    } else if filtered.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "tray")
                                .font(.title2)
                                .foregroundStyle(.secondary)
                            Text("No hay donaciones")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    } else {
                        List {
                            ForEach(filtered) { item in
                                VStack(spacing: 8) {
                                    Button {
                                        selected = item
                                    } label: {
                                        AdminDonationRow(donation: item.donation)
                                            .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.plain)

                                    Divider()
                                        .padding(.horizontal, 0)
                                        .padding(.top, -10)
                                }
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 0, trailing: 16))
                                .listRowSeparator(.hidden)
                            }
                        }
                        .listStyle(.plain)
                        .environment(\.defaultMinListRowHeight, 44)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.title2.bold())
                            .foregroundStyle(.gray)
                    }
                }
            }
            // Destino de navegación programática
            .navigationDestination(item: $selected) { item in
                AdminDonationDetailView(donation: item.donation, donationId: item.documentId)
            }
        }
    }
}

// MARK: - ViewModel (Implementación Main con Listeners)
@MainActor
final class AdminReviewsVM: ObservableObject {
    @Published var donations: [DonationWithId] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var listener: ListenerRegistration?
    private var isInitialized = false

    init() {
        // Initialize with empty values
    }

    func initialize() async {
        guard !isInitialized else { return }
        isInitialized = true
        
        isLoading = true
        
        startListening()
        
        isLoading = false
    }

    func startListening() {
        // No inicializa si ya hay un listener activo
        guard listener == nil else { return }
        
        listener = Firestore.firestore().collection("donations")
            .addSnapshotListener { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                        return
                    }
                    
                    guard let snapshot = snapshot else { return }
                    
                    // Crear array con documentID incluido
                    var donationsWithId: [DonationWithId] = []
                    
                    for doc in snapshot.documents {
                        if var donation = try? doc.data(as: Donation.self) {
                            // Si el donation no tiene id, asignar el documentID
                            if donation.id == nil {
                                donation.id = doc.documentID
                            }
                            donationsWithId.append(
                                DonationWithId(donation: donation, documentId: doc.documentID)
                            )
                        }
                    }
                    
                    // Ordenar por fecha descendente
                    donationsWithId.sort { 
                        let date0 = ($0.donation.day?.dateValue() ?? Date.distantPast).timeIntervalSince1970
                        let date1 = ($1.donation.day?.dateValue() ?? Date.distantPast).timeIntervalSince1970
                        return date0 > date1
                    }
                    
                    self?.donations = donationsWithId
                    self?.errorMessage = nil
                }
            }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    deinit {
        DispatchQueue.main.async { [weak self] in
            self?.stopListening()
        }
    }
}

// MARK: - Badge (Conservado de Sprint 1)
private struct StatusBadge: View {
    let status: String

    private var config: (text: String, color: Color) {
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

// MARK: - Preview (Conservado de Main)
#if DEBUG
private extension AdminReviewsVM {
    static func previewPopulated() -> AdminReviewsVM {
        let vm = AdminReviewsVM()
        vm.isLoading = false
        vm.errorMessage = nil
        vm.donations = AdminReviewsView_Previews.makeDummyDonations()
        return vm
    }
    static func previewEmpty() -> AdminReviewsVM {
        let vm = AdminReviewsVM()
        vm.isLoading = false
        vm.errorMessage = nil
        vm.donations = []
        return vm
    }
    static func previewLoading() -> AdminReviewsVM {
        let vm = AdminReviewsVM()
        vm.isLoading = true
        vm.errorMessage = nil
        vm.donations = []
        return vm
    }
    static func previewError() -> AdminReviewsVM {
        let vm = AdminReviewsVM()
        vm.isLoading = false
        vm.errorMessage = "No se pudo conectar con el servidor."
        vm.donations = []
        return vm
    }
}

struct AdminReviewsView_Previews: PreviewProvider {
    static func makeDummyDonations() -> [DonationWithId] {
        let now = Date()
        let urls = [
            "https://picsum.photos/seed/1/200/200",
            "https://picsum.photos/seed/2/200/200",
            "https://picsum.photos/seed/3/200/200"
        ]
        let mk: (String, String, String, Date, [String]) -> DonationWithId = { id, status, title, date, photos in
            let donation = Donation(
                id: id,
                bazarId: ["Alameda","Centro","Norte"].randomElement(),
                categoryId: ["Ropa", "Electrodomésticos", "Muebles", "Juguetes"],
                day: Timestamp(date: date),
                description: "Descripción de ejemplo para \(title.lowercased()).",
                adminComment: nil,
                folio: "FOL-\(id)",
                photoUrls: photos,
                status: status,
                title: title,
                userId: "U-\(Int.random(in: 1...99))",
                needsTransportHelp: Bool.random()
            )
            return DonationWithId(donation: donation, documentId: id)
        }

        return [
            mk("D-001", "pending",  "Ropa de invierno", now.addingTimeInterval(-3600), [urls[0]]),
            mk("D-002", "approved", "Silla de madera",   now.addingTimeInterval(-86400 * 1), [urls[1], urls[2]]),
            mk("D-003", "rejected", "Juguetes varios",   now.addingTimeInterval(-86400 * 2), []),
            mk("D-004", "pending",  "Televisor 32\"",    now.addingTimeInterval(-86400 * 3), [urls[2]]),
            mk("D-005", "approved", "Mesa de centro",    now.addingTimeInterval(-86400 * 5), [urls[0], urls[1], urls[2]])
        ]
    }

    static var previews: some View {
        Group {
            // Poblado
            AdminReviewsViewWrapper(vm: .previewPopulated())
                .previewDisplayName("Populado")

            // Vacío
            AdminReviewsViewWrapper(vm: .previewEmpty())
                .previewDisplayName("Vacío")

            // Cargando
            AdminReviewsViewWrapper(vm: .previewLoading())
                .previewDisplayName("Cargando")

            // Error
            AdminReviewsViewWrapper(vm: .previewError())
                .previewDisplayName("Error")
        }
        .environmentObject(AuthViewModel())
    }

    // Wrapper para inyectar el VM de preview sin tocar la vista principal
    private struct AdminReviewsViewWrapper: View {
        @StateObject var vm: AdminReviewsVM
        @State private var showSettings = false
        @State private var selection: AdminReviewsView.Filter = .all

        var body: some View {
            TabView(selection: $selection) {
                ReviewsScreen(filter: .all, vm: vm, showSettings: $showSettings)
                    .tabItem { Label("Todas", systemImage: "tray") }
                    .tag(AdminReviewsView.Filter.all)
                ReviewsScreen(filter: .pending, vm: vm, showSettings: $showSettings)
                    .tabItem { Label("Pendientes", systemImage: "clock.badge.exclamationmark") }
                    .tag(AdminReviewsView.Filter.pending)
                ReviewsScreen(filter: .approved, vm: vm, showSettings: $showSettings)
                    .tabItem { Label("Aprobadas", systemImage: "checkmark.seal") }
                    .tag(AdminReviewsView.Filter.approved)
                ReviewsScreen(filter: .rejected, vm: vm, showSettings: $showSettings)
                    .tabItem { Label("Rechazadas", systemImage: "xmark.seal") }
                    .tag(AdminReviewsView.Filter.rejected)
                ReviewsScreen(filter: .delivered,
                                      vm: vm,
                                      showSettings: $showSettings)
                            .tabItem { Label("Entregadas", systemImage: "checkmark.circle") }
                            .tag(AdminReviewsView.Filter.delivered)
                
            }
        }
    }
}
#endif
