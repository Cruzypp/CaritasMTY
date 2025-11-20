//
//  ErrorTranslator.swift
//  caritas
//
//  Created by ChatGPT on 19/11/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

enum ErrorTranslator {
    /// Traduce errores comunes de Firebase (Auth y Firestore) y de red al español.
    static func translate(_ error: Error) -> String {
        let ns = error as NSError

        // 1) Errores de Firebase Auth
        if let code = AuthErrorCode(rawValue: ns.code) {
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
                break
            }
        }

        // 2) Errores de Firestore (por dominio y/o mensajes/códigos conocidos)
        if ns.domain == FirestoreErrorDomain {
            // Mapeo por código de Firestore usando el enum Code directamente
            if let code = FirestoreErrorCode.Code(rawValue: ns.code) {
                switch code {
                case .permissionDenied:
                    return "Permisos insuficientes. No tienes autorización para realizar esta acción."
                case .unauthenticated:
                    return "No autenticado. Inicia sesión para continuar."
                case .notFound:
                    return "Recurso no encontrado."
                case .alreadyExists:
                    return "El recurso ya existe."
                case .failedPrecondition:
                    return "Condición previa no cumplida para realizar esta operación."
                case .aborted:
                    return "Operación abortada. Intenta nuevamente."
                case .resourceExhausted:
                    return "Se excedieron los recursos disponibles. Intenta más tarde."
                case .cancelled:
                    return "Operación cancelada."
                case .deadlineExceeded:
                    return "Tiempo de espera agotado. Verifica tu conexión e intenta de nuevo."
                case .unavailable:
                    return "Servicio no disponible temporalmente. Intenta más tarde."
                case .internal:
                    return "Error interno del servidor."
                case .dataLoss:
                    return "Pérdida de datos. Intenta nuevamente."
                case .unknown:
                    // Caeremos a heurística por mensaje
                    break
                default:
                    // Cubrir cualquier caso futuro del enum externo
                    break
                }
            }

            // Heurística por mensaje (por si llega como string crudo)
            let msg = ns.localizedDescription.lowercased()
            if msg.contains("missing or insufficient permissions") {
                return "Permisos insuficientes. No tienes autorización para realizar esta acción."
            }
            if msg.contains("permission denied") {
                return "Permisos insuficientes. No tienes autorización para realizar esta acción."
            }
            if msg.contains("deadline exceeded") || msg.contains("timeout") {
                return "Tiempo de espera agotado. Verifica tu conexión e intenta de nuevo."
            }
            if msg.contains("unavailable") {
                return "Servicio no disponible temporalmente. Intenta más tarde."
            }
            if msg.contains("not found") {
                return "Recurso no encontrado."
            }
            if msg.contains("unauthenticated") {
                return "No autenticado. Inicia sesión para continuar."
            }
        }

        // 3) Errores de red genéricos (NSURLErrorDomain)
        if ns.domain == NSURLErrorDomain {
            switch ns.code {
            case NSURLErrorNotConnectedToInternet:
                return "Sin conexión a internet. Verifica tu red e intenta de nuevo."
            case NSURLErrorTimedOut:
                return "Tiempo de espera agotado. Verifica tu conexión e intenta de nuevo."
            case NSURLErrorNetworkConnectionLost:
                return "Conexión a la red perdida. Intenta nuevamente."
            case NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost:
                return "No se pudo conectar con el servidor. Intenta más tarde."
            case NSURLErrorDNSLookupFailed:
                return "Error de DNS. Verifica tu conexión."
            default:
                break
            }
        }

        // 4) Fallback: devolver el mensaje original si no se reconoció
        return ns.localizedDescription
    }
}
