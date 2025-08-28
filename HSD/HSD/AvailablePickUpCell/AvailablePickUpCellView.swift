//
//  AvailablePickUpCellView.swift
//  HSD
//
//  Created by Justin Lee on 8/26/25.
//

import SwiftUI

struct AvailablePickUpCellView: View {
    var viewModel: AvailablePickUpCellViewModel
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                if let startAddress = viewModel.startAddress {
                    HStack {
                        Text("🟢")
                        Text("\(startAddress)")
                            .multilineTextAlignment(.leading)
                    }
                }
                
                if let endAddress = viewModel.endAddress {
                    HStack {
                        Text("🛑")
                        Text("\(endAddress)")
                            .multilineTextAlignment(.leading)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .leading) {
                Text("\(viewModel.estimatedEarnings)")
                
                Text("Score: \(viewModel.score)")
            }
        }
        .padding()
    }
}

#Preview {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .currency
    numberFormatter.locale = Locale(identifier: "en_US")
    
    let ride = Ride(endsAt: Date(), estimatedEarningsCents: 0, estimatedRideMiles: 0.0, estimatedRideMinutes: 0, commuteRideMiles: 0.0, commuteRideMinutes: 0, score: 0.0, orderedWaypoints: [], overviewPolyline: "", startsAt: Date(), tripUuid: UUID().uuidString, uuid: nil)
    
    let viewModel = AvailablePickUpCellViewModel(formatter: numberFormatter, ride: ride)
    return AvailablePickUpCellView(viewModel: viewModel)
}
