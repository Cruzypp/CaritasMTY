//
//  SwiftUIView.swift
//  caritas
//
//  Created by Cruz Yael Pérez González on 04/11/25.
//

import SwiftUI

struct BaazarCard: View {
    
    @State var nombre: String
    @State var categoria: String
    @State var horarios: String
    @State var imagen: Image
    
    var body: some View {
        GroupBox {
            
        } label: {
            HStack(){
                imagen
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(.rect(cornerRadius: 15))
                
                VStack(alignment: .leading){
                    
                    ZStack {
                        Text(nombre)
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(6)
                            .foregroundStyle(.white)
                            .frame(width: 190)
                    }
                    .background(Color(.morado))
                    .clipShape(.rect(cornerRadius: 10))
                    
                    HStack{
                        VStack(alignment: .leading ){
                            Text(horarios)
                                .fontWeight(.medium)
                            
                            Text(categoria)
                                .fontWeight(.light)
                        }
                        
                        Image(systemName: "mappin.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding(.leading, 35)
                    }
                }
                .padding(.leading, 20)
                .shadow(radius: 2)
            }
        }
        .frame(width: 350, height: 120)
    }
}

#Preview {
    BaazarCard(nombre: "Bazar 1", categoria: "Comida", horarios: "10:00-18:00", imagen: Image(.logotipo))
}
