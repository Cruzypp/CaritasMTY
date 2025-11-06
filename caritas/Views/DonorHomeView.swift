//
//  DonorHomeView.swift
//  caritas
//
//  Created by Juan Luis Alvarez Cisneros on 31/10/25.
//

import SwiftUI

struct DonorHomeView: View {
    @EnvironmentObject var auth: AuthViewModel
    @State private var showLogoutConfirm = false
    @State private var showHomeView = false
    
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
                        .font(.gotham(.bold, style: .title2))
                        .foregroundStyle(brand.primary)
                        .multilineTextAlignment(.center)
                    Text("""
"Servíos por amor, los unos a los otros". (Gál 5,13)
""")
                    .font(.gotham(.bold, style: .body))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                }
                
                
                // HIGHLIGHTS
                LazyVGrid(
                    columns: [.init(.flexible(), spacing: 16, alignment: .trailing), .init(.flexible(), spacing: 16, alignment: .leading)],
                    spacing: 15
                ) {
                    ForEach(highlights, id: \.title) { h in
                        VStack(alignment: .center, spacing: 10) {
                            Image(systemName: h.systemIcon)
                                .font(.title3)
                                .foregroundStyle(brand.accent)
                                .frame(height: 28)
                            VStack(alignment: .center, spacing: 2) {
                                Text(h.value)
                                    .font(.gotham(.bold, style: .headline))
                                    .foregroundStyle(brand.primary)
                                    .lineLimit(1)
                                Text(h.title)
                                    .font(.gotham(.regular, style: .footnote))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .frame(width: 155, height: 140)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(brand.surface)
                        )
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                
                // MISIÓN
                VStack(alignment: .leading, spacing: 12) {
                    Text("Misión")
                        .font(.gotham(.bold, style: .headline))
                        .foregroundStyle(brand.primary)
                    Text("Cáritas de Monterrey, A.B.P. es un organismo de la Iglesia Católica, fundamentado en el amor, que proporciona servicios asistenciales, de promoción humana y desarrollo comunitario a nuestros hermanos más desprotegidos, sin distinción de credo o religión.")
                        .font(.gotham(.regular, style: .body))
                        .foregroundStyle(.secondary)
                }
                .frame(width: 300, height: 190, alignment: .topLeading)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(brand.surface)
                )
                .padding(.horizontal)
                
                // VISIÓN
                VStack(alignment: .leading, spacing: 12) {
                    Text("Visión")
                        .font(.gotham(.bold, style: .headline))
                        .foregroundStyle(brand.primary)
                    Text("Contar con un liderazgo que optimice recursos y multiplique los servicios asistenciales, de promoción humana y administrativos; atendiendo a los más desprotegidos con infraestructura adecuada y personas en capacitación continua, comprometidas por amor.")
                        .font(.gotham(.regular, style: .body))
                        .foregroundStyle(.secondary)
                }
                .frame(width: 300, height: 180, alignment: .topLeading)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(brand.surface)
                )
                .padding(.horizontal)
                
                // VALORES
                VStack(alignment: .leading, spacing: 4) {
                    Text("Valores")
                        .font(.gotham(.bold, style: .body))
                        .foregroundStyle(brand.primary)
                    
                    LazyVGrid(columns:
                                [.init(.flexible(), alignment: .leading),
                                 .init(.flexible(), alignment: .leading)], spacing: 4) {
                                     ForEach(["Caridad", "Espiritualidad", "Servicio", "Humildad", "Respeto", "Profesionalismo", "Mejora continua"], id: \.self) { item in
                                         HStack(spacing: 4) {
                                             Circle()
                                                 .fill(brand.accent)
                                                 .frame(width: 6, height: 6)
                                             Text(item)
                                                 .font(.gotham(.regular, style: .subheadline))
                                                 .foregroundStyle(.secondary)
                                                 .lineLimit(2)
                                                 .padding(.leading, 10)
                                         }
                                         .frame(height: 30)
                                     }
                                 }
                }
                .frame(width: 300, height: 160, alignment: .topLeading)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(brand.surface)
                )
                .padding(.horizontal)
                
                // CTA suave
                VStack(spacing: 8) {
                    Text("Tu ayuda transforma vidas")
                        .font(.gotham(.bold, style: .headline))
                        .foregroundStyle(brand.primary)
                    Text("Súmate como donante o voluntario. Juntos llegamos más lejos.")
                        .font(.gotham(.regular, style: .body))
                        .padding(.top, 10)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(width: 300)
                .padding(.top, 24)
                .padding(.bottom, 24)
                
                // Botón OK para ir a HomeView
                Button(action: {
                    showHomeView = true
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.headline)
                        Text("OK")
                            .font(.gotham(.bold, style: .headline))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.azulMarino)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        .background(Color(.systemGroupedBackground))
        .fullScreenCover(isPresented: $showHomeView) {
            HomeView()
        }
        .transaction { transaction in
            transaction.animation = .easeInOut(duration: 0.5)
        }
    }
}

// MARK: - Preview

#Preview {
    DonorHomeView()
        .environmentObject(AuthViewModel())
}
