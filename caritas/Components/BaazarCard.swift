//
//  SwiftUIView.swift
//  caritas
//
//  Created by Cruz Yael Pérez González on 04/11/25.
//

import SwiftUI

struct BaazarCard: View {
    
    @State var nombre: String
    @State var horarios: String
    @State var telefono: String
    @State var imagen: Image
    
    var body: some View {
        GroupBox {
            
        } label: {
            HStack(){
                imagen
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(.rect(cornerRadius: 15))
                
                VStack(alignment: .leading, spacing: 8){
                    
                    ZStack {
                        Text(nombre)
                            .font(.gotham(.bold, style: .title3))
                            .padding(6)
                            .foregroundStyle(.white)
                            .frame(width: 190)
                    }
                    .background(Color(.morado))
                    .clipShape(.rect(cornerRadius: 10))
                    
                    HStack{
                        VStack(alignment: .leading, spacing: 4){
                            HStack(spacing: 4) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.gray)
                                Text(horarios)
                                    .font(.gotham(.regular, style: .caption))
                            }
                            
                            HStack(spacing: 4) {
                                Image(systemName: "phone.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.gray)
                                Text(telefono)
                                    .font(.gotham(.regular, style: .caption))
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "mappin.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                    .frame(width: 185)
                }
                .padding(.leading, 20)
                .shadow(radius: 2)
            }
        }
        .frame(width: 350, height: 120)
    }
}

#Preview {
    BaazarCard(nombre: "Bazar 1", horarios: "10:00-18:00", telefono: "81 8335 2214", imagen: Image(.logotipo))
}
