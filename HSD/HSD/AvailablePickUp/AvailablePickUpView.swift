//
//  AvailablePickUpView.swift
//  HSD
//
//  Created by Justin Lee on 8/26/25.
//

import SwiftUI

struct AvailablePickUpView: View {
    var viewModel: AvailablePickUpViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.cellViewModels) { viewModel in
                    AvailablePickUpCellView(viewModel: viewModel)
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
    AvailablePickUpView(viewModel: AvailablePickUpViewModel())
}
