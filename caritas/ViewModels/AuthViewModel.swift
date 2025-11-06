//
//  AuthViewModel.swift
//  caritas
//
//  Created by Juan Luis Alvarez Cisneros on 31/10/25.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var role: String?          // ← nuevo
    @Published var error: String?
    @Published var isLoading = false

    var isAdmin: Bool { role == "admin" } // ← helper

    private let db = Firestore.firestore()
    private var authHandle: AuthStateDidChangeListenerHandle?

    init() {
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }
            self.user = user
            Task { await self.loadProfile() } // carga role tras cambios de sesión
        }
    }
    deinit { if let h = authHandle { Auth.auth().removeStateDidChangeListener(h) } }

    private func loadProfile() async {
        guard let uid = Auth.auth().currentUser?.uid else { role = nil; return }
        do {
            let snap = try await db.collection("users").document(uid).getDocument()
            self.role = (snap.data()?["role"] as? String) ?? "donador"
        } catch {
            self.role = "donador"
        }
    }

    func signIn(email: String, password: String) async {
        guard !email.isEmpty, !password.isEmpty else { return }
        isLoading = true; defer { isLoading = false }
        do {
            _ = try await Auth.auth().signIn(withEmail: email, password: password)
            error = nil
            await loadProfile()
        } catch { self.error = (error as NSError).localizedDescription }
    }

    func signUp(email: String, password: String, acceptedPolicies: Bool) async {
        guard !email.isEmpty, !password.isEmpty, acceptedPolicies else {
            error = "Debes aceptar las políticas."
            return
        }
        isLoading = true; defer { isLoading = false }
        do {
            let res = try await Auth.auth().createUser(withEmail: email, password: password)
            try await db.collection("users").document(res.user.uid).setData([
                "email": email,
                "role": "donador",
                "acceptedPoliciesAt": FieldValue.serverTimestamp()
            ], merge: true)
            error = nil
            await loadProfile()
        } catch { self.error = (error as NSError).localizedDescription }
    }

    func signOut() {
        try? Auth.auth().signOut()
        user = nil
        role = nil
    }
}
