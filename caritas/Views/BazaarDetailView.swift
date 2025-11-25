//
//  BazaarDetailView.swift
//  caritas
//
//  Created by Cruz Yael Pérez González on 07/11/25.
//

import SwiftUI
import MapKit

struct BazaarDetailView: View {

    let bazar: Bazar
    @State private var showCallAlert = false
    @State private var phoneNumber: String = ""
    @State private var goToMap: Bool = false

    // 👉 Navegación al DonateView
    @State private var goToDonate = false

    // 👉 Alerta cuando el bazar no acepta donaciones
    @State private var showClosedDonateAlert = false

    private let columns = [
        GridItem(.adaptive(minimum: 120), spacing: 10, alignment: .leading)
    ]

    var body: some View {

        ScrollView {
            VStack(spacing: 20) {

                // ==========================
                // HEADER FOTO
                // ==========================
                ZStack(alignment: .bottomLeading) {

                    Image(.bazar)
                        .resizable()
                        .scaledToFill()

                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(.azulMarino).opacity(0.8),
                            Color.clear
                        ]),
                        startPoint: .bottom,
                        endPoint: .center
                    )

                    Text(bazar.nombre ?? "Sin ubicación")
                        .font(.gotham(.bold, style: .title))
                        .padding(15)
                        .foregroundStyle(.white)
                }
                .frame(width: 350, height: 250)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(radius: 3)

                // ==========================
                // BANNER NO ACEPTANDO DONACIONES
                // ==========================
                if bazar.acceptingDonations == false {
                    HStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.headline)
                            .foregroundColor(.yellow)

                        Text("Actualmente NO está aceptando donaciones")
                            .font(.gotham(.regular, style: .subheadline))
                            .foregroundColor(.primary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.yellow.opacity(0.25))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                }

                // ==========================
                // CATEGORÍAS
                // ==========================
                VStack(alignment: .leading) {
                    Text("Categorías")
                        .font(.gotham(.bold, style: .headline))
                        .padding(.horizontal)

                    FlowLayout(spacingX: 10, spacingY: 12) {
                        ForEach(Array(bazar.categorias ?? [:]), id: \.key) { key, value in
                            PillComponent(categoria: value)
                        }
                    }
                    .padding(.horizontal, 36)
                }

                // ==========================
                // HORARIOS
                // ==========================
                VStack {
                    ScheduleComponent(horario: bazar.horarios ?? "")
                }
                .padding(.horizontal)

                // ==========================
                // TELÉFONO
                // ==========================
                HStack {
                    Text("Teléfono:")
                        .font(.gotham(.bold, style: .headline))
                        .padding(.horizontal)

                    Spacer()

                    if let numero = bazar.telefono?.replacingOccurrences(of: " ", with: "") {
                        Button {
                            phoneNumber = numero
                            showCallAlert.toggle()
                        } label: {
                            Label(bazar.telefono ?? "00 0000 0000",
                                  systemImage: "phone.fill")
                                .foregroundStyle(.aqua)
                        }
                        .padding(.trailing)
                    }
                }
                .padding(.vertical, 5)

                // ==========================
                // MAPA
                // ==========================
                Button {
                    goToMap.toggle()
                } label: {
                    MapComponent(
                        nombre: bazar.nombre ?? "bazar",
                        lat: bazar.latitude ?? 0.0,
                        lon: bazar.longitude ?? 0.0,
                        address: bazar.address ?? "Sin dirección"
                    )
                }
                .padding(.horizontal)

                // ==========================
                // NAVEGACIÓN OCULTA -> DONATE VIEW
                // ==========================
                .navigationDestination(isPresented: $goToDonate) {
                    DonateView(preselectedBazar: bazar)
                }

                // ==========================
                // BOTÓN DONAR
                // ==========================
                Button {

                    if bazar.acceptingDonations == false {
                        showClosedDonateAlert = true
                        return
                    }

                    goToDonate = true

                } label: {
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
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        )
                }
                .tint(Color.aqua)
                .shadow(radius: 10)
                .padding(.top, 10)

            }
        }
        // ==========================
        // ALERTA: LLAMADA
        // ==========================
        .alert("¿Llamar a \(phoneNumber)?", isPresented: $showCallAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Llamar") { call(to: phoneNumber) }
        }

        // ==========================
        // ALERTA: BAZAR CERRADO AL DONAR
        // ==========================
        .alert("Bazar no disponible", isPresented: $showClosedDonateAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("\(bazar.nombre ?? "Este bazar") actualmente no está aceptando donaciones. Por favor elige otro bazar.")
        }

        // ==========================
        // NAVEGACIÓN -> MAPA COMPLETO
        // ==========================
        .navigationDestination(isPresented: $goToMap) {
            FullMapComponent(
                nombre: bazar.nombre ?? "bazar",
                lat: bazar.latitude ?? 0.0,
                lon: bazar.longitude ?? 0.0
            )
        }
    }

    private func call(to rawNumber: String?) {
        let digits = (rawNumber ?? "")
            .components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()

        if let url = URL(string: "telprompt://\(digits)") {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    let bazar = Bazar(
        id: "bazar_001",
        acceptingDonations: false,
        address: "Florencio Antillón 1223, Centro, Monterrey, N.L., C.P 64720",
        categoryIds: ["0", "1", "2"],
        location: "Divina Providencia",
        nombre: "Divina Providencia",
        latitude: 25.668611658866286,
        longitude: -100.30311610397051,
        horarios: "Lunes a Viernes 9:00 a.m. a 6:00 p.m.; Sábados 10:00 a.m. a 6:00 p.m.",
        telefono: "81 8340 4077",
        categorias: [
            "0": "Electrónica",
            "1": "Ferretería",
            "2": "Juguetes",
            "3": "Muebles",
            "4": "Personal"
        ]
    )

    NavigationStack {
        BazaarDetailView(bazar: bazar)
            .environmentObject(AuthViewModel())
    }
}
