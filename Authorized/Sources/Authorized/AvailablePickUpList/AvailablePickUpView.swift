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
            
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            } else {
                ErrorView(viewModel: viewModel.errorViewModel)
            }
        }
    }
}

#Preview {
    let eventPublisher = PassthroughSubject<AvailablePickUpEvent, Never>()
    let viewModel = AvailablePickUpViewModel(numberFormatter: NumberFormatter(), eventPublisher: eventPublisher, availableRideService: AvailableRidesService())
    return AvailablePickUpView(viewModel: viewModel)
}
