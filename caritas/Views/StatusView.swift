//
//  StatusView.swift
//  caritas
//
//  Created by Cruz Yael Pérez González on 04/11/25.
//

import SwiftUI
import Foundation


struct StatusView: View {
    @StateObject private var viewModel: StatusViewModel
    @State private var selectedDonation: Donation?
    
    init(isDummy: Bool = false) {
        _viewModel = StateObject(wrappedValue: StatusViewModel(isDummy: isDummy))
    }

    var body: some View {
        NavigationStack{
            VStack(alignment: .leading, spacing: 0){
                Text("Estatus de\nDonaciones")
                    .padding(.top, 40)
                    .padding(.leading, 20)
                    .font(.gotham(.bold, style: .largeTitle))
                    .foregroundColor(.azulMarino)
                
                // Picker Segmentado
                Picker("Estado", selection: $viewModel.selectedStatus) {
                    ForEach(StatusViewModel.DonationStatus.allCases, id: \.self) { status in
                        Text(status.rawValue).tag(status)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
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
                } else if viewModel.filteredAndSortedDonations.isEmpty {
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
                        ForEach(viewModel.filteredAndSortedDonations, id: \.id) { donation in
                            StatusCard(donation: donation)
                                .padding(.vertical, -9)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedDonation = donation
                                }
                            .listRowSeparator(.hidden)
                            .buttonStyle(.plain)
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await viewModel.loadDonations()
                    }
                    .environment(\.defaultMinListRowHeight, 0)
                    .navigationDestination(item: $selectedDonation) { donation in
                        DonationDetailView(donation: donation)
                    }
                }
            }
        }
        .task {
            await viewModel.loadDonations()
        }
    }
}

#Preview {
    StatusView(isDummy: true)
}
