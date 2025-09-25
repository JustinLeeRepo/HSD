//
//  AvailablePickUpView.swift
//  HSD
//
//  Created by Justin Lee on 8/26/25.
//

import Combine
import NetworkService
import SharedUI
import SwiftUI

struct AvailablePickUpView: View {
    @Bindable var viewModel: AvailablePickUpViewModel
    
    var body: some View {
        switch viewModel.state {
        case .error(let errorViewModel):
            ErrorView(viewModel: errorViewModel)
        case .loading:
            ProgressView()
        case .success(let cellViewModels):
            generateList(cellViewModels: cellViewModels)
        case .empty:
            ContentUnavailableView("No Pickups Available", systemImage: "circle.slash")
        }
    }
    
    private func generateList(cellViewModels: [AvailablePickUpCellViewModel]) -> some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(cellViewModels) { cellViewModel in
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
    }
}

#Preview {
    let eventPublisher = PassthroughSubject<AvailablePickUpEvent, Never>()
    let viewModel = AvailablePickUpViewModel(numberFormatter: NumberFormatter(), eventPublisher: eventPublisher, availableRideService: AvailableRidesService())
    return AvailablePickUpView(viewModel: viewModel)
}
