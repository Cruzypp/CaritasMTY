//
//  DebouncedTextField.swift
//  caritas
//
//  TextField optimizado con debouncing para reducir búsquedas excesivas
//

import SwiftUI
import Combine

struct DebouncedTextField: View {
    let placeholder: String
    @Binding var text: String
    let onDebounce: (String) -> Void
    let debounceDelay: TimeInterval
    
    @State private var internalText = ""
    @State private var debounceTask: Task<Void, Never>?
    
    var body: some View {
        TextField(placeholder, text: $internalText)
            .onChange(of: internalText) { oldValue, newValue in
                debounceTask?.cancel()
                text = newValue
                
                debounceTask = Task {
                    try? await Task.sleep(nanoseconds: UInt64(debounceDelay * 1_000_000_000))
                    if !Task.isCancelled {
                        onDebounce(newValue)
                    }
                }
            }
            .onAppear {
                internalText = text
            }
    }
}

// Extension de Publisher para debouncing (alternativa)
extension Publisher {
    func debounce(delay: TimeInterval) -> Publishers.Debounce<Self, DispatchQueue> {
        debounce(for: .milliseconds(Int(delay * 1000)), scheduler: DispatchQueue.main)
    }
}
