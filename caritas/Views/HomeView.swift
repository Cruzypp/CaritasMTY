import SwiftUI
import MapKit

struct BaazarUI: Identifiable, Equatable {
    var id = UUID()
    var address: String?
    var horario: String?
    var categoryIds: [Category]?
    var location: String?
    var imagen: Image?
}

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
    @State private var showLogoutConfirm = false

    private let sampleBazaars: [BaazarUI] = [
        BaazarUI(
            address: "Av. Juárez 102, Puebla, Pue.",
            horario: "9:00–18:00",
            categoryIds: [.food, .toys],
            location: "Centro Histórico",
            imagen: Image(.logotipo)
        ),
        BaazarUI(
            address: "Calle Hidalgo 56, Cholula, Pue.",
            horario: "10:00–17:00",
            categoryIds: [.clothes, .furniture],
            location: "Plaza Principal",
            imagen: Image(.logotipo)
        ),
        BaazarUI(
            address: "Blvd. Atlixco 2001, Puebla, Pue.",
            horario: "9:00–15:00",
            categoryIds: [.medicine, .food],
            location: "Parque Ecológico",
            imagen: Image(.logotipo)
        ),
        BaazarUI(
            address: "Av. Reforma 350, Puebla, Pue.",
            horario: "11:00–20:00",
            categoryIds: [.furniture, .toys],
            location: "Zona Rosa",
            imagen: Image(.logotipo)
        ),
        BaazarUI(
            address: "Calle 25 Sur 1410, Puebla, Pue.",
            horario: "10:00–19:00",
            categoryIds: [.clothes, .medicine, .food],
            location: "Colonia El Carmen",
            imagen: Image(.logotipo)
        )
    ]

    @State private var search = ""

    private var filteredBazaars: [BaazarUI] {
        guard !search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return sampleBazaars
        }
        let q = search.lowercased()
        return sampleBazaars.filter { b in
            (b.location?.lowercased().contains(q) ?? false) ||
            (b.address?.lowercased().contains(q) ?? false) ||
            (b.horario?.lowercased().contains(q) ?? false) ||
            (b.categoryIds?.map { $0.rawValue.lowercased() }.joined(separator: " ").contains(q) ?? false)
        }
    }

    @State private var goToNotifications: Bool = false

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

                // Lista de bazares
                List {
                    ForEach(filteredBazaars) { bazar in
                        NavigationLink {
                            Text(bazar.location ?? "Detalle")
                                .font(.gotham(.regular, style: .body))
                        } label: {
                            BaazarCard(
                                nombre: bazar.location ?? (bazar.address ?? "Sin nombre"),
                                categoria: (bazar.categoryIds ?? [])
                                    .map { $0.rawValue }
                                    .joined(separator: ", ")
                                    .ifEmpty("Sin categoría"),
                                horarios: bazar.horario ?? "—",
                                imagen: bazar.imagen ?? Image(.logotipo)
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
            }
            .padding(.top, 30)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        showLogoutConfirm = true
                    }) {
                        Image(systemName: "power.circle.fill")
                            .font(.title2)
                            .foregroundColor(.naranja)
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
            .confirmationDialog("¿Cerrar sesión?", isPresented: $showLogoutConfirm, titleVisibility: .visible) {
                Button("Cerrar sesión", role: .destructive) {
                    auth.signOut()
                }
                Button("Cancelar", role: .cancel) { }
            }
            .navigationDestination(isPresented: $goToNotifications){
                StatusView()
            }
        }
    }
}

private extension String {
    func ifEmpty(_ replacement: @autoclosure () -> String) -> String {
        isEmpty ? replacement() : self
    }
}

#Preview {
    HomeView()
}
