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
    
    private let columns = [
        GridItem(.adaptive(minimum: 120), spacing: 10, alignment: .leading)
    ]
    
    var body: some View {
        
        NavigationStack{
            ScrollView{
                VStack{
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
                            .foregroundStyle(Color(.white))
                    }
                    .frame(width: 350, height: 250)
                    .clipped()
                    .clipShape(.rect(cornerRadius: 15))
                    .shadow(radius: 3)
                    
                    VStack() {
                        Text("Categorías")
                            .font(.gotham(.bold, style: .headline))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                        
                        FlowLayout(spacingX: 10, spacingY: 12) {
                            ForEach(Array(bazar.categorias ?? [:]), id: \.key) { key, value in
                                
                                PillComponent(categoria: value)
                            }
                        }
                        .padding(.horizontal, 36)
                    }
                    .padding(.horizontal)
                    
                    VStack{
                        ScheduleComponent(horario: bazar.horarios ?? "")
                    }
                    .padding()
                    
                    HStack{
                        Text("Teléfono:")
                            .font(.gotham(.bold, style: .headline))
                            .padding(.horizontal)
                        
                        Spacer()
                        
                        if let numero = bazar.telefono?.replacingOccurrences(of: " ", with: "") {
                            Button{
                                phoneNumber = numero
                                showCallAlert.toggle()
                            } label: {
                                Label(bazar.telefono ?? "00 0000 0000", systemImage: "phone.fill")
                                    .foregroundStyle(.aqua)
                            }
                            .padding(.trailing)
                        }
                        
                    }
                    .padding()
                    
                    
                    Button{
                        goToMap.toggle()
                    } label: {
                        MapComponent(nombre: bazar.nombre ?? "bazar", lat: bazar.latitude ?? 0.0, lon: bazar.longitude ?? 0.0, address: bazar.address ?? "Sin dirección")
                    }
                }
            }
            .alert("¿Llamar a \(phoneNumber)?", isPresented: $showCallAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Llamar") {
                    call(to: phoneNumber)
                }
            }
            .navigationDestination(isPresented: $goToMap){
                FullMapComponent(nombre: bazar.nombre ?? "bazar", lat: bazar.latitude ?? 0.0, lon: bazar.longitude ?? 0.0)
            }
        }
    }
    
    private func call(to rawNumber: String?) {
        
        // Hacer que solo sean dígitos
        let digits = (rawNumber ?? "")
            .components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()

        if let url = URL(string: "telprompt://\(digits)") {
            UIApplication.shared.open(url)
            return
        }
    }
}

#Preview {
    let bazar = Bazar(
        id: "bazar_001",
        acceptingDonations: true,
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
    BazaarDetailView( bazar: bazar)
        .environmentObject(AuthViewModel())
}
