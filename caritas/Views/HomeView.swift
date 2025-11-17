//HomeView.swift

import SwiftUI
import MapKit

enum Category: String, CaseIterable, Identifiable {
    case food = "Comida"
    case medicine = "Medicamento"
    case clothes = "Ropa"
    case furniture = "Muebles"
    case toys = "Juguetes"
    var id: String { rawValue }
}

struct HomeView: View {
    @EnvironmentObject var auth: AuthViewModel
    @StateObject private var viewModel = HomeViewModel()
    @State private var showLogoutConfirm = false
    @State private var search = ""
    @State private var goToNotifications: Bool = false
    @FocusState private var searchFocused: Bool

    private var filteredBazaars: [Bazar] {
        viewModel.searchBazares(query: search)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                

                NavigationLink { DonateView() } label: {
                    Text("DONAR")
                        .font(.gotham(.bold, style: .title2))
                        .frame(width: 250, height: 60)
                        .foregroundStyle(.white)
                }
                .buttonBorderShape(.roundedRectangle(radius: 20))
                .buttonStyle(.borderedProminent)
                .tint(Color.aqua)
                .shadow(radius: 10)
                .frame(maxWidth: .infinity)

                Text("Bazares")
                    .font(.gotham(.bold, style: .largeTitle))
                    .padding(.top, 10)
                    .padding(.horizontal, 20)

                // Buscador
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass").foregroundColor(.gray)
                    TextField("Buscar bazar…", text: $search)
                        .font(.gotham(.regular, style: .body))
                        .textFieldStyle(.plain)
                        .autocorrectionDisabled()
                        .focused($searchFocused)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal, 20)

                // Lista
                if viewModel.isLoading {
                    VStack { ProgressView() }
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle").font(.title).foregroundColor(.red)
                        Text(error).font(.gotham(.regular, style: .body)).multilineTextAlignment(.center)
                        Button("Reintentar") { viewModel.fetchBazares() }
                            .buttonStyle(.borderedProminent).tint(Color.aqua)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .padding(20)
                } else if filteredBazaars.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass").font(.title).foregroundColor(.gray)
                        Text("No se encontraron bazares").font(.gotham(.regular, style: .body))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    List {
                        ForEach(filteredBazaars) { bazar in
                            NavigationLink {
                                BazaarDetailView(bazar: bazar)
                            } label: {
                                BaazarCard(
                                    nombre: bazar.nombre ?? bazar.location ?? (bazar.address ?? "Sin nombre"),
                                    horarios: bazar.horarios ?? "-",
                                    telefono: bazar.telefono ?? "-",
                                    isAcceptingDonations: bazar.acceptingDonations ?? true
                                )
                            }
                            .buttonStyle(.plain)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .padding(.top, -8)
                    .scrollDismissesKeyboard(.immediately)
                }
            }
            .padding(.top, 30)
            .onAppear { viewModel.fetchBazares() }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        DonorSettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.title2.bold())
                            .foregroundStyle(.gray)
                            .frame(width: 50, height: 50)
                            .background(Color.white.opacity(0.9))
                            .clipShape(Circle())
                            .shadow(radius: 3)
                    }
                    .accessibilityLabel("Cerrar sesión")
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button { goToNotifications.toggle() } label: {
                        Text("Donaciones")
                            .fontWeight(.bold)
                    }
                }

                // Botón para ocultar teclado
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Ocultar") { searchFocused = false }  // 👈
                }
            }
            .alert("¿Cerrar sesión?", isPresented: $showLogoutConfirm) {
                Button("Cancelar", role: .cancel) { }
                Button("Cerrar sesión", role: .destructive) { auth.signOut() }
            } message: {
                Text("¿Estás seguro de que deseas cerrar sesión?")
            }
            .navigationDestination(isPresented: $goToNotifications) { StatusView() }
        }
        .navigationBarBackButtonHidden(true)
    }
    
}


#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}
