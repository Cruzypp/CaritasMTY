//
//  test.swift
//  caritas
//
//  Created by Cruz Yael Pérez González on 06/11/25.
//

import SwiftUI

struct MultiPickerInForm: View {
    let airdropOptions = [
        "Receiving Off",
        "Contacts Only",
        "Everyone for 10 minutes"
    ]
    
    // Ahora es un Set, no un String
    @State private var selectedOptions: Set<String> = []
    @State private var showPicker = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("AirDrop") {
                    // Botón que muestra el resumen y abre el "picker"
                    Button {
                        showPicker.toggle()
                    } label: {
                        HStack {
                            Text("AirDrop Options")
                            Spacer()
                            if selectedOptions.isEmpty {
                                Text("Ninguna")
                                    .foregroundStyle(.secondary)
                            } else {
                                Text(selectedOptions.joined(separator: ", "))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            // MARK: - Sheet con opciones
            .sheet(isPresented: $showPicker) {
                NavigationStack {
                    List(airdropOptions, id: \.self) { option in
                        Button {
                            toggle(option)
                        } label: {
                            HStack {
                                Text(option)
                                Spacer()
                                if selectedOptions.contains(option) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }
                    }
                    .navigationTitle("Select Options")
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") {
                                showPicker = false
                            }
                            .bold()
                        }
                    }
                }
            }
        }
    }
    
    // Alterna selección
    private func toggle(_ option: String) {
        if selectedOptions.contains(option) {
            selectedOptions.remove(option)
        } else {
            selectedOptions.insert(option)
        }
    }
}

#Preview {
    MultiPickerInForm()
}
