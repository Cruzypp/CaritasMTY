//
//  PrivacyNoticeView.swift
//  caritas
//
//  Created by Juan Luis Alvarez Cisneros on 31/10/25.
//

import SwiftUI

struct PrivacyNoticeView: View {
    @Environment(\.dismiss) var dismiss

    // Colores de Assets
    private let brandPrimary = Color("azulMarino")
    private let brandAccent  = Color("aqua")
    private let surface      = Color("grisClaro")
    private let ink          = Color("negro")

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // Logo
                    Image("Logotipo Cáritas de Monterrey, A.B.P.")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 320)
                        .frame(maxWidth: .infinity) // <- centra horizontalmente
                    

                    // Título organizacional
                    Text("Cáritas de Monterrey, A.B.P.")
                        .font(.gotham(.bold, style: .title2))
                        .foregroundStyle(brandPrimary)

                    // CONTENIDO TARJETA
                    VStack(alignment: .leading, spacing: 16) {

                        Group {
                            Text("Fundamento y objeto")
                                .font(.gotham(.bold, style: .headline))
                                .foregroundStyle(brandPrimary)

                            Text("""
CÁRITAS DE MONTERREY, A.B.P. pone a su disposición este Aviso de Privacidad conforme a la **Ley Federal de Protección de Datos Personales en Posesión de los Particulares** (LFPDPPP) y su Reglamento. Aquí indicamos **qué datos personales** podemos obtener, **para qué finalidades** se usan y **cómo los protegemos** mediante medidas físicas, técnicas y administrativas.
""")
                            .foregroundStyle(ink)
                        }

                        Divider().overlay(brandAccent.opacity(0.25))

                        Group {
                            Text("Responsable del tratamiento")
                                .font(.gotham(.bold, style: .headline))
                                .foregroundStyle(brandPrimary)

                            Text("""
CÁRITAS DE MONTERREY, A.B.P.  
**FRANCISCO G. SADA PTE 2810, OBISPADO, MONTERREY, NUEVO LEÓN, MÉXICO, C.P. 64040**.  
Somos responsables de **recabar**, **usar** y **proteger** sus datos personales.
""")
                            .foregroundStyle(ink)
                        }

                        Divider().overlay(brandAccent.opacity(0.25))

                        Group {
                            Text("A quiénes aplican estas disposiciones")
                                .font(.gotham(.bold, style: .headline))
                                .foregroundStyle(brandPrimary)

                            Text("Cuidamos en todo momento los datos personales de **beneficiarios, donantes, voluntarios, prestadores de servicio social** y el **personal** que labora en la institución.")
                                .foregroundStyle(ink)
                        }

                        // Finalidades principales
                        Group {
                            Text("Finalidades principales")
                                .font(.gotham(.bold, style: .headline))
                                .foregroundStyle(brandPrimary)

                            BulletList(items: [
                                "Captación de donativos.",
                                "Registro de donantes y pagos en línea.",
                                "Trámite de recibo deducible.",
                                "Difusión de información de áreas de servicio y campañas.",
                                "Donativos directos (únicos y/o recurrentes).",
                                "Invitaciones a presentaciones de campañas y nuevos programas.",
                                "Programas de apadrinamiento.",
                                "Voluntariado.",
                                "Generación de bases de datos."
                            ], accent: brandAccent, ink: ink)
                        }

                        // Finalidades secundarias
                        Group {
                            Text("Finalidades secundarias (opcionales)")
                                .font(.gotham(.bold, style: .headline))
                                .foregroundStyle(brandPrimary)

                            Text("Nos ayudan a brindarte una mejor atención, pero **no son indispensables** para el servicio:")
                                .foregroundStyle(ink)

                            BulletList(items: [
                                "Evaluar la calidad del servicio que brindamos.",
                                "Envío de boletines electrónicos.",
                                "Mercadotecnia o publicidad.",
                                "Estudios y programas para determinar hábitos de consumo."
                            ], accent: brandAccent, ink: ink)
                        }

                        // Limitar uso secundario
                        Group {
                            Text("¿Cómo limitar el uso para finalidades secundarias?")
                                .font(.gotham(.bold, style: .headline))
                                .foregroundStyle(brandPrimary)

                            Text("Si **no** deseas que tus datos se utilicen con finalidades secundarias, envía tu negativa a:")
                                .foregroundStyle(ink)

                            Link("caritas@caritas.org.mx",
                                 destination: URL(string: "mailto:caritas@caritas.org.mx")!)
                            .font(.callout.weight(.semibold))
                            .foregroundStyle(brandPrimary)
                            .padding(.vertical, 2)
                            .padding(.horizontal, 10)
                            .background(brandAccent.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }

                        // Cambios
                        Group {
                            Text("Cambios al Aviso de Privacidad")
                                .font(.gotham(.bold, style: .headline))
                                .foregroundStyle(brandPrimary)

                            Text("Cualquier modificación derivada de cambios administrativos, operativos o de la normatividad aplicable se notificará **a través del sitio web** de la institución.")
                                .foregroundStyle(ink)
                        }

                        // Derechos ARCO
                        Group {
                            Text("Derechos ARCO")
                                .font(.gotham(.bold, style: .headline))
                                .foregroundStyle(brandPrimary)

                            Text("""
El titular podrá ejercer en todo momento sus derechos de **Acceso, Rectificación, Cancelación y Oposición (ARCO)** mediante **aviso por escrito en las oficinas** de la institución, presentándose **debidamente identificado**.
""")
                            .foregroundStyle(ink)
                        }

                        // Fecha
                        HStack {
                            Image(systemName: "calendar")
                            Text("Última actualización: **08/01/2025**")
                                .font(.gotham(.regular, style: .body))
                        }
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)

                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(surface)
                    )

                    // ✅ BOTÓN CERRAR AL FINAL
                    Button {
                        dismiss()
                    } label: {
                        Text("Cerrar")
                            .font(.gotham(.bold, style: .headline))
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(brandPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.top, 10)
                }
                .padding(16)
            }
            .navigationTitle("Aviso de Privacidad")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct BulletList: View {
    let items: [String]
    let accent: Color
    let ink: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(items, id: \.self) { text in
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Circle()
                        .fill(accent)
                        .frame(width: 6, height: 6)
                        .padding(.top, 6)

                    Text(text)
                        .foregroundStyle(ink)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(.top, 2)
    }
}

#Preview {
    PrivacyNoticeView()
}
