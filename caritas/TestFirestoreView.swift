//
//  TestFirestoreView.swift
//  caritas
//
//  Created by Juan Luis Alvarez Cisneros on 31/10/25.
//

import SwiftUI

struct TestFirestoreView: View {
    @State private var bazaars: [Bazar] = []
    @State private var donations: [Donation] = []
    @State private var users: [UserDoc] = []
    @State private var log = "Pulsa “Cargar todo” para probar."
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            List {
                Section("Bazaars (\(bazaars.count))") {
                    ForEach(bazaars) { b in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(b.id ?? "—").font(.headline)
                            Text("Acepta: \(b.acceptingDonations == true ? "Sí" : "No")").font(.caption)
                            if let cats = b.categoryIds { Text("Categorías: \(cats.joined(separator: ", "))").font(.caption) }
                            if let addr = b.address, !addr.isEmpty { Text(addr).font(.caption) }
                        }
                    }
                }

                Section("Donations (\(donations.count))") {
                    ForEach(donations) { d in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(d.title ?? "—").font(.headline)
                            Text("Status: \(d.status ?? "—")  •  Folio: \(d.folio ?? "—")").font(.caption)
                            if let cats = d.categoryId { Text("Cat: \(cats.joined(separator: ", "))").font(.caption) }
                        }
                    }
                }

                Section("Users (\(users.count))") {
                    ForEach(users) { u in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(u.email ?? "—").font(.headline)
                            Text("Rol: \(u.rol ?? "—")").font(.caption)
                        }
                    }
                }

                Section("Log") { Text(log).font(.footnote).foregroundStyle(.secondary) }
            }
            .navigationTitle("Prueba Firestore")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(isLoading ? "Cargando…" : "Cargar todo") { Task { await loadAll() } }
                        .disabled(isLoading)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Ping don_001") { Task { await pingOne() } }
                }
            }
        }
    }

    private func loadAll() async {
        isLoading = true; defer { isLoading = false }
        do {
            async let b = FirestoreService.shared.fetchBazaars()
            async let d = FirestoreService.shared.fetchDonations()
            async let u = FirestoreService.shared.fetchUsers()
            (bazaars, donations, users) = try await (b, d, u)
            log = "OK ✅  \(bazaars.count) bazars, \(donations.count) donations, \(users.count) users."
        } catch {
            log = "Error al cargar: \(error.localizedDescription)"
        }
    }

    private func pingOne() async {
        do {
            let data = try await FirestoreService.shared.ping(documentPath: "donations/don_001")
            log = "Ping don_001: \(data)"
        } catch {
            log = "Ping falló: \(error.localizedDescription)"
        }
    }
}
