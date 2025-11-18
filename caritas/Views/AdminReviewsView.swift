//
//  AdminReviewsView.swift
//  caritas
//
//  Created by Juan Luis Alvarez Cisneros on 05/11/25.
//

import SwiftUI
import Combine
import FirebaseFirestore

// MARK: - Helper struct para mantener el documentID
struct DonationWithId {
    let donation: Donation
    let documentId: String
    
    var uniqueId: String { 
        // Preferir donation.id si existe, sino usar documentId
        donation.id ?? documentId
    }
}
struct AdminReviewsView: View {
    @EnvironmentObject var auth: AuthViewModel
    @StateObject private var vm = AdminReviewsVM()

    enum Filter: String, CaseIterable, Identifiable, Hashable {
        case all = "Todas"
        case pending = "Pendientes"
        case approved = "Aprobadas"
        case rejected = "Rechazadas"
        var id: String { rawValue }
    }

    @State private var selection: Filter = .all
    @State private var showSettings = false

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
        }
        .task {
            await vm.initialize()
        }
        // 🔥 Configuración como SHEET a pantalla completa (tapa el TabView)
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                AdminSettingsView()
                    .environmentObject(auth)
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

    var body: some View {
        let azul  = Color("azulMarino")

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
            }
            
            return statusFiltered
        }()

        return NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
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
                            ForEach(filtered, id: \.documentId) { item in
                                NavigationLink {
                                    AdminDonationDetailView(donation: item.donation, donationId: item.documentId)
                                } label: {
                                    AdminDonationRow(donation: item.donation)
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
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.title2.bold())
                            .foregroundStyle(.gray)
                    }
                }
            }
        }
    }
}

// MARK: - Row (miniatura con primera foto si existe)
private struct AdminDonationRow: View {
    let donation: Donation

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6))

                if let first = donation.photoUrls?.first,
                   let url = URL(string: first) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 56, height: 56)
                                .clipped()
                        case .empty:
                            ProgressView()
                        default:
                            Image(systemName: "photo.on.rectangle.angled")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    Image(systemName: "photo.on.rectangle.angled")
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 6) {
                Text(donation.title ?? "—")
                    .font(.headline)

                if let desc = donation.description, !desc.isEmpty {
                    Text(desc)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                HStack(spacing: 8) {
                    StatusBadge(status: donation.status ?? "pending")
                    if let ts = donation.day {
                        Text(ts.dateValue().formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Badge
private struct StatusBadge: View {
    let status: String
    var config: (text: String, color: Color) {
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

// MARK: - ViewModel
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
        
        do {
            // Cargar donaciones iniciales - pero necesitamos el documentID
            // Por eso usaremos directamente el listener
            startListening()
        } catch {
            errorMessage = (error as NSError).localizedDescription
        }
        
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

// MARK: - Preview
#Preview {
    AdminReviewsView()
        .environmentObject(AuthViewModel())
}
