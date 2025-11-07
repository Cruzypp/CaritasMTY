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

    private var filteredBazaars: [Bazar] {
        viewModel.searchBazares(query: search)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {

                // Navegación correcta con NavigationLink (empuja DonateView en el mismo stack)
                NavigationLink {
                    DonateView()
                } label: {
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

                // Título
                Text("Bazares")
                    .font(.gotham(.bold, style: .largeTitle))
                    .padding(.top, 10)
                    .padding(.horizontal, 20)

                // Buscador
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Buscar bazar…", text: $search)
                        .font(.gotham(.regular, style: .body))
                        .textFieldStyle(.plain)
                        .autocorrectionDisabled()
                    Button {
                        // futuro filtro avanzado
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .onTapGesture {
                    // Cierra el teclado cuando se toca el search bar
                    hideKeyboard()
                }

                // Lista de bazares
                if viewModel.isLoading {
                    VStack {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.title)
                            .foregroundColor(.red)
                        Text(error)
                            .font(.gotham(.regular, style: .body))
                            .multilineTextAlignment(.center)
                        Button("Reintentar") {
                            viewModel.fetchBazares()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.aqua)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .padding(20)
                } else if filteredBazaars.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.title)
                            .foregroundColor(.gray)
                        Text("No se encontraron bazares")
                            .font(.gotham(.regular, style: .body))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    List {
                        ForEach(filteredBazaars) { bazar in
                            NavigationLink {
                                Text(bazar.location ?? "Detalle")
                                    .font(.gotham(.regular, style: .body))
                            } label: {
                                BaazarCard(
                                    nombre: bazar.nombre ?? bazar.location ?? (bazar.address ?? "Sin nombre"),
                                    horarios: bazar.horarios ?? "—",
                                    telefono: bazar.telefono ?? "—",
                                    imagen: Image(.logotipo)
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
                    .onTapGesture {
                        // Cierra el teclado cuando se toca la lista
                        hideKeyboard()
                    }
                }
            }
            .padding(.top, 30)
            .onTapGesture {
                // Cierra el teclado cuando se toca cualquier parte de la pantalla
                hideKeyboard()
            }
            .onAppear {
                viewModel.fetchBazares()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        showLogoutConfirm = true
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.forward.fill")
                            .imageScale(.medium)
                            .foregroundColor(.black)
                            .environment(\.layoutDirection, .rightToLeft)
                    }
                    .accessibilityLabel("Cerrar sesión")
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        goToNotifications.toggle()
                    } label: {
                        Image(systemName: "bell.fill")
                            .imageScale(.large)
                    }
                }
            }
            .alert("¿Cerrar sesión?", isPresented: $showLogoutConfirm) {
                Button("Cancelar", role: .cancel) { }
                Button("Cerrar sesión", role: .destructive) {
                    auth.signOut()
                }
            } message: {
                Text("¿Estás seguro de que deseas cerrar sesión?")
            }
            .navigationDestination(isPresented: $goToNotifications){
                StatusView()
            }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

private extension String {
    func ifEmpty(_ replacement: @autoclosure () -> String) -> String {
        isEmpty ? replacement() : self
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}
