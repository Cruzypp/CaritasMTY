// HomeView.swift

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
    @State private var isPulsing: Bool = false
    @State private var isTapped: Bool = false
    @FocusState private var searchFocused: Bool
    
    private var filteredBazaars: [Bazar] {
        viewModel.searchBazares(query: search)
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                
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
                        .submitLabel(.search)
                        .onSubmit { searchFocused = false }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal, 20)
                
                // Lista de Bazares
                if viewModel.isLoading {
                    VStack { ProgressView() }
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.title)
                            .foregroundColor(.red)
                        Text(error)
                            .font(.gotham(.regular, style: .body))
                            .multilineTextAlignment(.center)
                        
                        Button("Reintentar") { viewModel.fetchBazares() }
                            .buttonStyle(.borderedProminent)
                            .tint(Color.aqua)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(20)
                } else if filteredBazaars.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.title)
                            .foregroundColor(.gray)
                        Text("No se encontraron bazares")
                            .font(.gotham(.regular, style: .body))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                
               
                ZStack {
                    Color.clear
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                    
                    NavigationLink { DonateView() } label: {
                        Text("DONAR")
                            .font(.gotham(.bold, style: .title2))
                            .frame(width: 250, height: 60)
                            .foregroundStyle(.white)
                            .background(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        Color.aqua,
                                        Color.aqua.mix(with: .white, by: 0.10).opacity(0.9)
                                    ]),
                                    center: .center,
                                    startRadius: 30,
                                    endRadius: 220
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            )
                    }
                    .tint(Color.aqua)
                    .shadow(radius: 10)
                    .scaleEffect(isPulsing ? 1.1 : 1)
                    .animation(.easeInOut(duration: 1.2).repeatCount(3, autoreverses: true), value: isPulsing)
                    .scaleEffect(isTapped ? 0.9585 : 1.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isTapped)
                    .overlay(
                        Group {
                            if isTapped {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.white.opacity(0.18))
                                    .blendMode(.multiply)
                            }
                        }
                    )
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in isTapped = true }
                            .onEnded { _ in isTapped = false }
                    )
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 15)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                        isPulsing = true
                    }
                }
                
            }
            .padding(.top, 5)
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
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button { goToNotifications.toggle() } label: {
                        Text("Donaciones").fontWeight(.bold)
                    }
                }
                
                // Botón para ocultar teclado
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Ocultar") { searchFocused = false }
                }
            }
            .alert("¿Cerrar sesión?", isPresented: $showLogoutConfirm) {
                Button("Cancelar", role: .cancel) {}
                Button("Cerrar sesión", role: .destructive) { auth.signOut() }
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
