//
//  AdminReviewView.swift
//  caritas
//

import SwiftUI
import FirebaseAuth

struct AdminReviewView: View {
    @State private var pending: [Donation] = []
    @State private var loading = false
    @State private var msg: String?

    var body: some View {
        NavigationStack {
            List {
                if let m = msg {
                    Text(m).foregroundColor(.secondary)
                }

                if loading {
                    ProgressView("Cargando…")
                }

                ForEach(pending) { d in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(d.title ?? "—")
                                .font(.headline)
                            Spacer()
                            Text(d.folio ?? "")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        if let desc = d.description, !desc.isEmpty {
                            Text(desc).font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }

                        HStack(spacing: 8) {
                            Button("Aprobar") {
                                Task { await setStatus(d, to: "approved") }
                            }
                            .buttonStyle(.borderedProminent)

                            Button("Rechazar") {
                                Task { await setStatus(d, to: "rejected") }
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Revisión (pendientes)")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task { await load() }
                    } label: { Image(systemName: "arrow.clockwise") }
                        .disabled(loading)
                }
            }
            .task { await load() }
        }
    }

    private func load() async {
        loading = true; defer { loading = false }
        do {
            pending = try await FirestoreService.shared.pendingDonations()
            if pending.isEmpty { msg = "No hay donaciones pendientes." } else { msg = nil }
        } catch {
            msg = "Error: \(error.localizedDescription)"
        }
    }

    private func setStatus(_ d: Donation, to status: String) async {
        guard let id = d.id,
              let reviewer = Auth.auth().currentUser?.uid else {
            msg = "No hay usuario autenticado."
            return
        }
        do {
            try await FirestoreService.shared.setDonationStatus(
                donationId: id,
                status: status,
                reviewerId: reviewer
            )
            // Quita del listado local:
            pending.removeAll { $0.id == id }
            if pending.isEmpty { msg = "No hay donaciones pendientes." } else { msg = "Actualizado a \(status)." }
        } catch {
            msg = "Error: \(error.localizedDescription)"
        }
    }
}

#Preview {
    AdminReviewView()
}
