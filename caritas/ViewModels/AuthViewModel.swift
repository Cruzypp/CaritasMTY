//
//  AuthViewModel.swift
//  caritas
//
//  Created by Juan Luis Alvarez Cisneros on 31/10/25.
//

import Foundation
import Combine
import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import GoogleSignIn

@MainActor
final class AuthViewModel: ObservableObject {
    // Estado de sesión
    @Published var user: User?
    @Published var role: String?              // "admin" | "donador" | "adminBazar"
    @Published var bazarId: String?          // bazar asignado (solo para adminBazar)
    @Published var error: String?
    @Published var isLoading = false

    var isAdmin: Bool {
        (role ?? "").lowercased() == "admin"
    }

    var isBazarAdmin: Bool {
        (role ?? "").lowercased() == "adminbazar"
    }

    private let db = Firestore.firestore()
    private var authHandle: AuthStateDidChangeListenerHandle?

    // MARK: - Init / Listener
    init() {
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }
            self.user = user
            Task { await self.loadProfile() }
        }
    }

    deinit {
        if let h = authHandle {
            Auth.auth().removeStateDidChangeListener(h)
        }
    }

    // MARK: - Perfil (rol + bazar)
    private func loadProfile() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            role = nil
            bazarId = nil
            return
        }
        do {
            let snap = try await db.collection("users").document(uid).getDocument()
            let data = snap.data() ?? [:]

            // Acepta "role" o "rol"
            let storedRole = (data["role"] as? String) ?? (data["rol"] as? String) ?? "donador"
            self.role = storedRole

            // bazarId solo aplica para adminBazar, pero si existe lo guardamos igual
            self.bazarId = data["bazarId"] as? String
        } catch {
            self.role = "donador"
            self.bazarId = nil
        }
    }

    // MARK: - Email / Password
    func signIn(email: String, password: String) async {
        guard !email.isEmpty, !password.isEmpty else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            _ = try await Auth.auth().signIn(withEmail: email, password: password)
            self.error = nil
            await loadProfile()
        } catch {
            self.error = translateFirebaseError(error)
        }
    }

    func signUp(email: String, password: String, acceptedPolicies: Bool) async {
        guard !email.isEmpty, !password.isEmpty, acceptedPolicies else {
            self.error = "Debes aceptar las políticas."
            return
        }
        isLoading = true
        defer { isLoading = false }
        do {
            let res = try await Auth.auth().createUser(withEmail: email, password: password)
            try await db.collection("users").document(res.user.uid).setData([
                "email": email,
                "role": "donador",
                "acceptedPoliciesAt": FieldValue.serverTimestamp()
            ], merge: true)
            self.error = nil
            await loadProfile()
        } catch {
            self.error = translateFirebaseError(error)
        }
    }

    // MARK: - Google Sign-In
    func signInWithGoogle() async {
        isLoading = true
        defer { isLoading = false }

        do {
            // 1) Configurar GoogleSignIn con el clientID del plist
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                self.error = "No se encontró clientID de Google."
                return
            }
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

            // 2) Presentador (UIViewController superior)
            guard let presentingVC = Self.topViewController() else {
                self.error = "No se pudo obtener el presentador para Google."
                return
            }

            // 3) Lanzar flujo de Google (SDK nuevo)
            let result = try await withCheckedThrowingContinuation { (cont: CheckedContinuation<GIDSignInResult, Error>) in
                GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) { signInResult, err in
                    if let err { cont.resume(throwing: err); return }
                    guard let signInResult else {
                        cont.resume(throwing: NSError(
                            domain: "GoogleSignIn",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Resultado nulo"]
                        ))
                        return
                    }
                    cont.resume(returning: signInResult)
                }
            }

            // 4) Credencial Firebase
            guard let idToken = result.user.idToken?.tokenString else {
                self.error = "No se obtuvo idToken de Google."
                return
            }
            let accessToken = result.user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

            // 5) Login en Firebase
            let authRes = try await Auth.auth().signIn(with: credential)
            self.user = authRes.user
            self.error = nil

            // 6) Crear/actualizar doc en /users al primer login
            let uid = authRes.user.uid
            let email = authRes.user.email ?? ""
            let userDoc = db.collection("users").document(uid)
            let snap = try await userDoc.getDocument()
            if !snap.exists {
                // Para cuentas nuevas: role = donador por defecto, sin bazarId
                try await userDoc.setData([
                    "email": email,
                    "role": "donador",
                    "createdAt": FieldValue.serverTimestamp(),
                    "provider": "google"
                ])
            } else {
                // Mantener role y bazarId existentes; si no hay role, poner "donador"
                let existingRole = (snap.data()?["role"] as? String) ?? "donador"
                try await userDoc.setData(["role": existingRole], merge: true)
            }

            // 7) Rol + bazarId en memoria
            await loadProfile()

        } catch {
            // Ignorar error si el usuario canceló
            let nsError = error as NSError
            let errorDesc = nsError.localizedDescription.lowercased()
            
            // Detectar cancelación por código o por mensaje
            if nsError.code == -2 || 
               errorDesc.contains("canceled") || 
               errorDesc.contains("cancelled") ||
               errorDesc.contains("user cancelled") {
                self.error = nil
            } else {
                self.error = nsError.localizedDescription
            }
        }
    }

    // MARK: - SignOut
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
            self.role = nil
            self.bazarId = nil
            self.error = nil
        } catch {
            self.error = (error as NSError).localizedDescription
        }
    }

    // MARK: - Helpers
    
    /// Traduce errores de Firebase al español
    private func translateFirebaseError(_ error: Error) -> String {
        let nsError = error as NSError
        
        // Errores comunes de Firebase Auth
        if let code = AuthErrorCode(rawValue: nsError.code) {
            switch code {
            case .invalidEmail:
                return "El correo electrónico no es válido."
            case .userNotFound:
                return "No existe una cuenta con este correo electrónico."
            case .wrongPassword:
                return "La contraseña es incorrecta."
            case .userDisabled:
                return "Esta cuenta ha sido deshabilitada."
            case .tooManyRequests:
                return "Demasiados intentos fallidos. Intenta más tarde."
            case .operationNotAllowed:
                return "Esta operación no está permitida."
            case .emailAlreadyInUse:
                return "Este correo electrónico ya está registrado."
            case .weakPassword:
                return "La contraseña es muy débil. Debe tener al menos 6 caracteres."
            case .accountExistsWithDifferentCredential:
                return "Ya existe una cuenta con este correo electrónico."
            case .requiresRecentLogin:
                return "Debes iniciar sesión recientemente para realizar esta acción."
            case .invalidCredential:
                return "Las credenciales son inválidas."
            default:
                return nsError.localizedDescription
            }
        }
        
        return nsError.localizedDescription
    }
    
    /// Encuentra el UIViewController superior para presentar el flujo de Google
    private static func topViewController(base: UIViewController? = nil) -> UIViewController? {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive })

        let root = base ?? scene?.keyWindow?.rootViewController
        if let nav = root as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = root as? UITabBarController {
            return topViewController(base: tab.selectedViewController)
        }
        if let presented = root?.presentedViewController {
            return topViewController(base: presented)
        }
        return root
    }
}

// Pequeña utilidad para iOS 15+ (keyWindow)
private extension UIWindowScene {
    var keyWindow: UIWindow? {
        return self.windows.first(where: { $0.isKeyWindow })
    }
}
