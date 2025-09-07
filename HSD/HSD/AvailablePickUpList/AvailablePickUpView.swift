//
//  AvailablePickUpView.swift
//  HSD
//
//  Created by Justin Lee on 8/26/25.
//

import Combine
import SwiftUI
import NetworkService

struct AvailablePickUpView: View {
    var viewModel: AvailablePickUpViewModel
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.cellViewModels) { cellViewModel in
                        Button {
                            viewModel.navigateDetail(cellViewModel: cellViewModel)
                        } label: {
                            AvailablePickUpCellView(viewModel: cellViewModel)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(.label).opacity(0.1), lineWidth: 1)
                                        .shadow(color: Color(.label), radius: 2.0, x: 0, y: 0)
                                }
                                .padding(.horizontal)
                        }
                    }
                }
            }
            
            if let error = viewModel.error {
                Text(error.localizedDescription)
                    .padding()
                    .font(.caption)
                    .foregroundStyle(.pink)
                    .opacity(viewModel.error == nil ? 0 : 1)
            }
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
    }
}

#Preview {
    let eventPublisher = PassthroughSubject<AvailablePickUpEvent, Never>()
    let viewModel = AvailablePickUpViewModel(numberFormatter: NumberFormatter(), eventPublisher: eventPublisher, availableRideService: AvailableRidesService())
    return AvailablePickUpView(viewModel: viewModel)
}
