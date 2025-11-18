//
//  BazarAdminSettingsView.swift
//  caritas
//
//  Created by Juan Luis Alvarez Cisneros on 12/11/25.
//

import SwiftUI
import FirebaseAuth

struct BazarAdminSettingsView: View {
    @EnvironmentObject var auth: AuthViewModel
    @StateObject private var vm = BazarAdminSettingsVM()

    private let azul = Color("azulMarino")

    // Alert para confirmar que se dejarán de aceptar donaciones
    @State private var showStopDonationsAlert = false
    // Valor que el usuario intentó poner (false cuando apaga el switch)
    @State private var pendingToggleValue: Bool? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    // Icono de usuario
                    VStack(spacing: 8) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(azul)

                        Text("Administrador de bazar")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 32)

                    // Datos de cuenta
                    VStack(alignment: .leading, spacing: 16) {

                        Text("Cuenta")
                            .font(.gotham(.bold, style: .headline))

                        // Email (solo lectura)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Email")
                                .font(.gotham(.bold, style: .caption))
                                .foregroundColor(.gray)

                            Text(auth.user?.email ?? "admin@bazar.com")
                                .font(.gotham(.regular, style: .body))
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)

                    // Switch de aceptar donaciones
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Operación del bazar")
                            .font(.gotham(.bold, style: .headline))

                        Toggle(
                            isOn: Binding(
                                get: { vm.isAcceptingDonations },
                                set: { newValue in
                                    guard let bazarId = auth.bazarId else { return }

                                    // Caso importante: estaba en true y el usuario lo apaga (true -> false)
                                    if vm.isAcceptingDonations == true && newValue == false {
                                        // Guardamos la intención del usuario y mostramos el alert
                                        pendingToggleValue = newValue
                                        showStopDonationsAlert = true
                                    } else {
                                        // Cualquier otro cambio (por ejemplo false -> true) se guarda directo
                                        vm.isAcceptingDonations = newValue
                                        Task {
                                            await vm.save(for: bazarId)
                                        }
                                    }
                                }
                            )
                        ) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Aceptar donaciones")
                                    .font(.gotham(.regular, style: .body))
                                Text("Si desactivas esta opción, los donantes ya no podrán seleccionar este bazar al crear una nueva donación.")
                                    .font(.gotham(.regular, style: .caption))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .toggleStyle(SwitchToggleStyle(tint: azul))
                    }
                    .padding(.horizontal)

                    if let err = vm.error {
                        Text(err)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }

                    // Botón de logout
                    Button {
                        auth.signOut()
                    } label: {
                        Text("Cerrar sesión")
                            .font(.gotham(.bold, style: .body))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(azul)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    Spacer(minLength: 20)
                }
            }
            .navigationTitle("Configuración")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            // Solo carga desde Firestore; NO dispara el alert porque
            // el binding del Toggle solo ejecuta el setter cuando el usuario lo mueve.
            guard let bazarId = auth.bazarId else { return }
            await vm.load(for: bazarId)
        }
        // Alert de confirmación solo cuando el admin apaga el switch
        .alert("¿Dejar de aceptar donaciones?", isPresented: $showStopDonationsAlert) {
            Button("Cancelar", role: .cancel) {
                // Revertimos el cambio: volvemos a true
                vm.isAcceptingDonations = true
                pendingToggleValue = nil
            }
            Button("Confirmar", role: .destructive) {
                guard let bazarId = auth.bazarId else { return }
                // Aplicamos el valor pendiente (false) y guardamos
                vm.isAcceptingDonations = pendingToggleValue ?? false
                pendingToggleValue = nil
                Task {
                    await vm.save(for: bazarId)
                }
            }
        } message: {
            Text("Los donantes ya no podrán seleccionar este bazar al crear nuevas donaciones.")
        }
    }
}

// MARK: - Preview

struct BazarAdminSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        let auth = AuthViewModel()
        auth.role = "adminBazar"
        auth.bazarId = "Alameda"   // fake ID para preview

        return BazarAdminSettingsView()
            .environmentObject(auth)
    }
}
