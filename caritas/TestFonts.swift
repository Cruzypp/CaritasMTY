//
//  TestFonts.swift
//  caritas
//
//  Created by Cruz Yael Pérez González on 05/11/25.
//

import SwiftUI

struct TestFonts: View {
    var body: some View {
        Text("Hola")
            .font(.gotham(.regular, style: .body))
    }
    
    init(){
        for familyfonts in UIFont.familyNames {
            print(familyfonts)
            
            for fontName in UIFont.fontNames(forFamilyName: familyfonts){
                print("----\(fontName)")
            }
        }
    }
}

#Preview {
    TestFonts()
}
