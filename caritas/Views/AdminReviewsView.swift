//
//  AdminReviewsView.swift
//  caritas
//
//  Created by Juan Luis Alvarez Cisneros on 05/11/25.
//

import SwiftUI
import Combine
import FirebaseFirestore

// MARK: - View (contenedor con TabView abajo)
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

    var body: some View {
        TabView(selection: $selection) {
            ReviewsScreen(filter: .all, vm: vm)
                .tabItem { Label("Todas", systemImage: "tray") }
                .tag(Filter.all)

            ReviewsScreen(filter: .pending, vm: vm)
                .tabItem { Label("Pendientes", systemImage: "clock.badge.exclamationmark") }
                .tag(Filter.pending)

            ReviewsScreen(filter: .approved, vm: vm)
                .tabItem { Label("Aprobadas", systemImage: "checkmark.seal") }
                .tag(Filter.approved)

            ReviewsScreen(filter: .rejected, vm: vm)
                .tabItem { Label("Rechazadas", systemImage: "xmark.seal") }
                .tag(Filter.rejected)
        }
        .task { await vm.loadAll() }
    }
}

// MARK: - Pantalla filtrada
private struct ReviewsScreen: View {
    let filter: AdminReviewsView.Filter
    @ObservedObject var vm: AdminReviewsVM
    @EnvironmentObject var auth: AuthViewModel

    private let azul  = Color("azulMarino")

    private var filtered: [Donation] {
        switch filter {
        case .all:       return vm.donations
        case .pending:   return vm.donations.filter { ($0.status ?? "pending").lowercased() == "pending" }
        case .approved:  return vm.donations.filter { ($0.status ?? "").lowercased() == "approved" }
        case .rejected:  return vm.donations.filter { ($0.status ?? "").lowercased() == "rejected" }
        }
    }

    var body: some View {
        NavigationStack {
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
                    } else if let err = vm.error {
                        VStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.title2)
                                .foregroundStyle(.red)
                            Text("Error al cargar")
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
                            ForEach(filtered, id: \.id) { donation in
                                NavigationLink {
                                    AdminDonationDetailView(donation: donation)
                                } label: {
                                    AdminDonationRow(donation: donation)
                                }
                                .buttonStyle(.plain)
                                .listRowSeparator(.hidden)
                            }
                        }
                        .listStyle(.plain)
                        .refreshable { await vm.loadAll() }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Botón de logout en esquina superior derecha (menú con engrane)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(role: .destructive) {
                            auth.signOut()
                        } label: {
                            Label("Cerrar sesión", systemImage: "rectangle.portrait.and.arrow.right")
                        }
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

                if let first = donation.photoUrls?.first, let url = URL(string: first) {
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

            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Badge
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

// MARK: - ViewModel
@MainActor
final class AdminReviewsVM: ObservableObject {
    @Published var donations: [Donation] = []
    @Published var isLoading: Bool = false
    @Published var error: String?

    func loadAll() async {
        isLoading = true
        defer { isLoading = false }

        do {
            donations = try await FirestoreService.shared.fetchDonations()
            self.error = nil
        } catch {
            // ⚠️ Evita sombrear la propiedad con la constante local del catch
            self.error = (error as NSError).localizedDescription
        }
    }
}

// MARK: - Preview
#Preview {
    AdminReviewsView()
        .environmentObject(AuthViewModel())
}
