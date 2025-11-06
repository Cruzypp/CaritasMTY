//
//  DonorHomeView.swift
//  caritas
//
//  Created by Juan Luis Alvarez Cisneros on 31/10/25.
//

import SwiftUI

struct DonorHomeView: View {
    @EnvironmentObject var auth: AuthViewModel

    // Colores desde Assets
    private let brand = (
        primary: Color("azulMarino"),
        accent:  Color("aqua"),
        surface: Color("grisClaro"),
        ink:     Color("negro")
    )

    // Pequeños KPIs para dar contexto
    private let highlights: [(title: String, value: String, systemIcon: String)] = [
        ("Personas beneficiadas", "376,460", "person.3.fill"),
        ("Toneladas distribuidas", "7,315", "shippingbox.fill"),
        ("Voluntariado", "8,046", "hands.sparkles.fill"),
        ("Clínicas & Posadas", "3 + 3", "cross.case.fill")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // LOGO + TITULAR
                    VStack(spacing: 12) {
                        // Centrado del logo
                        HStack { Spacer()
                            Image("Logito")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 400)
                            Spacer() }
                        Text("Cáritas de Monterrey, A.B.P.")
                            .font(.title2.bold())
                            .foregroundStyle(brand.primary)
                            .multilineTextAlignment(.center)
                        Text("“Servíos por amor, los unos a los otros”. (Gál 5,13)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                  

                    // HIGHLIGHTS
                    LazyVGrid(
                        columns: [.init(.flexible()), .init(.flexible())],
                        spacing: 12
                    ) {
                        ForEach(highlights, id: \.title) { h in
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: h.systemIcon)
                                    .font(.title3)
                                    .foregroundStyle(brand.accent)
                                    .frame(width: 28)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(h.value)
                                        .font(.headline)
                                        .foregroundStyle(brand.primary)
                                    Text(h.title)
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer(minLength: 0)
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(brand.surface)
                            )
                        }
                    }
                    .padding(.horizontal)

                    // MISIÓN
                    InfoCard(
                        title: "Misión",
                        color: brand.primary,
                        text:
"""
Cáritas de Monterrey, A.B.P. es un organismo de la Iglesia Católica, fundamentado en el amor, que proporciona servicios asistenciales, de promoción humana y desarrollo comunitario a nuestros hermanos más desprotegidos, sin distinción de credo o religión.
"""
                    )

                    // VISIÓN
                    InfoCard(
                        title: "Visión",
                        color: brand.primary,
                        text:
"""
Contar con un liderazgo que optimice recursos y multiplique los servicios asistenciales, de promoción humana y administrativos; atendiendo a los más desprotegidos con infraestructura adecuada y personas en capacitación continua, comprometidas por amor.
"""
                    )

                    // VALORES
                    ValuesCard(
                        title: "Valores",
                        color: brand.primary,
                        bullets: [
                            "Caridad", "Espiritualidad", "Servicio",
                            "Humildad", "Respeto", "Profesionalismo",
                            "Mejora continua"
                        ],
                        accent: brand.accent
                    )

                    // CTA suave
                    VStack(spacing: 8) {
                        Text("Tu ayuda transforma vidas")
                            .font(.headline)
                            .foregroundStyle(brand.primary)
                        Text("Súmate como donante o voluntario. Juntos llegamos más lejos.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom, 24)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .navigationTitle("Donaciones")
            .toolbar {
                // Botón de logout (izquierda)
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        showLogoutConfirm = true
                    }) {
                        Image(systemName: "power.circle.fill")
                            .font(.title2)
                            .foregroundColor(.naranja)
                    }
                }
                // HomeView (derecha)
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        Task { await donationVM.loadMyDonations() }
                    }) {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .font(.title2)
                            .foregroundColor(.azulMarino)
                    }
                    .accessibilityLabel("Actualizar")
                }
            }
            .background(Color(.systemGroupedBackground))
        }
    }
}

// MARK: - Subviews

private struct InfoCard: View {
    let title: String
    let color: Color
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(color)
            Text(text)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color("grisClaro"))
        )
    }
}

private struct ValuesCard: View {
    let title: String
    let color: Color
    let bullets: [String]
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(color)

            LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 8) {
                ForEach(bullets, id: \.self) { item in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(accent)
                            .frame(width: 6, height: 6)
                        Text(item)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color("grisClaro"))
        )
    }
}

// MARK: - Preview

#Preview {
    DonorHomeView()
        .environmentObject(AuthViewModel())
}
