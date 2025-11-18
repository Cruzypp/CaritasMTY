//
//  AllPhotosSheetView.swift
//  caritas
//
//  Created by Cruz Yael Pérez González on 14/11/25.
//

import SwiftUI

struct AllPhotosSheetView: View {
    let photoUrls: [String]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(Array(photoUrls.enumerated()), id: \.offset) { index, urlString in
                        if let url = URL(string: urlString) {
                            VStack(alignment: .leading, spacing: 8) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 250)
                                            .clipped()
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            
                                    case .failure(_):
                                        ZStack {
                                            Color(.systemGray6)
                                            Image(.logotipo)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 80, height: 80)
                                        }
                                        .frame(height: 250)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        
                                    case .empty:
                                        ZStack {
                                            Color(.systemGray6)
                                            ProgressView()
                                        }
                                        .frame(height: 250)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                
                                Text("Foto \(index + 1) de \(photoUrls.count)")
                                    .font(.gotham(.regular, style: .caption))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("Todas las fotos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Atrás")
                        }
                        .foregroundColor(.azulMarino)
                    }
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    AllPhotosSheetView(photoUrls: [
        "https://picsum.photos/400/300",
        "https://picsum.photos/400/301",
        "https://picsum.photos/400/302",
        "https://picsum.photos/400/303"
    ])
}
