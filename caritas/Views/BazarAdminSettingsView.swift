//
//  BazarAdminSettingsView.swift
//  caritas
//
//  Created by Juan Luis Alvarez Cisneros on 12/11/25.
//


//  BazarAdminSettingsView.swift

import SwiftUI
import FirebaseAuth

struct BazarAdminSettingsView: View {
    @EnvironmentObject var auth: AuthViewModel
    @StateObject private var vm = BazarAdminSettingsVM()

    private let azul = Color("azulMarino")

    // Hardcode de puntitos de contraseña
    private let fakePasswordDots = "••••••••••"

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

                        // Contraseña fake con puntitos
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Contraseña")
                                .font(.gotham(.bold, style: .caption))
                                .foregroundColor(.gray)

                            Text(fakePasswordDots)
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

                        Toggle(isOn: $vm.isAcceptingDonations) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Aceptar donaciones")
                                    .font(.gotham(.regular, style: .body))
                                Text("Si desactivas esta opción, los donantes ya no podrán seleccionar este bazar al crear una nueva donación.")
                                    .font(.gotham(.regular, style: .caption))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .toggleStyle(SwitchToggleStyle(tint: azul))
                        .onChange(of: vm.isAcceptingDonations) { newValue in
                            guard let bazarId = auth.bazarId else { return }
                            Task {
                                await vm.save(for: bazarId)
                            }
                        }
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
            guard let bazarId = auth.bazarId else { return }
            await vm.load(for: bazarId)
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
