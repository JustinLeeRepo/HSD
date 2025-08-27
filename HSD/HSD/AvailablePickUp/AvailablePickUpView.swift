//
//  AvailablePickUpView.swift
//  HSD
//
//  Created by Justin Lee on 8/26/25.
//

import Combine
import SwiftUI

struct AvailablePickUpView: View {
    var viewModel: AvailablePickUpViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(viewModel.cellViewModels) { cellViewModel in
                    Button {
                        viewModel.navigateDetail(cellViewModel: cellViewModel)
                    } label: {
                        AvailablePickUpCellView(viewModel: cellViewModel)
                    }
                }
            }
        }
        .task {
            await viewModel.fetchRide()
        }
        
        if let error = viewModel.error {
            Text(error.localizedDescription)
                .padding()
                .font(.caption)
                .foregroundStyle(.pink)
                .opacity(viewModel.error == nil ? 0 : 1)
        }
    }
}

#Preview {
    let eventPublisher = PassthroughSubject<AvailablePickUpEvent, Never>()
    let viewModel = AvailablePickUpViewModel(numberFormatter: NumberFormatter(), eventPublisher: eventPublisher)
    return AvailablePickUpView(viewModel: viewModel)
}
