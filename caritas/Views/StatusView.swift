//
//  StatusView.swift
//  caritas
//
//  Created by Cruz Yael Pérez González on 04/11/25.
//

import SwiftUI
import Foundation

struct StatusView: View {
    @StateObject private var viewModel = StatusViewModel()

    var body: some View {
        NavigationStack{
            VStack(alignment: .leading){
                Text("Estatus de\nDonaciones")
                    .padding(.top, 40)
                    .padding(.leading, 20)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.azulMarino)
                
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.title)
                            .foregroundColor(.red)
                        Text("Error al cargar")
                            .font(.headline)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else if viewModel.donations.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "box.circle")
                            .font(.title)
                            .foregroundColor(.gray)
                        Text("No hay donaciones")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    List{
                        ForEach(viewModel.donations, id: \.id) { donation in
                            NavigationLink(destination: DonationDetailView(donation: donation)) {
                                StatusCard(donation: donation)
                                    .padding(.vertical, -9)
                            }
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                }
            }
        }
        .task {
            await viewModel.loadDonations()
        }
    }
}

#Preview {
    StatusView()
}
