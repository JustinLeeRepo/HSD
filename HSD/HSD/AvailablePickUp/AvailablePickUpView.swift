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
                ForEach(viewModel.availableRides) { ride in
                    if let startAddress = ride.startAddress {
                        Text("Start Address: \(startAddress)")
                    }
                    
                    if let endAddress = ride.endAddress {
                        Text("End Address: \(endAddress)")
                    }
                    
                    Text("id : \(ride.id)")
                    
                    // TODO: convert to currency text
                    Text("estimated earnings: \(ride.estimatedEarningsCents)")
                    
                    Text("score: \(ride.score)")
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
