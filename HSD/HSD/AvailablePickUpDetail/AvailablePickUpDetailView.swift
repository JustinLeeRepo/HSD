//
//  AvailablePickUpDetailView.swift
//  HSD
//
//  Created by Justin Lee on 8/27/25.
//

import SwiftUI

struct AvailablePickUpDetailView: View {
    var viewModel: AvailablePickUpDetailViewModel
    
    var body: some View {
        //TODO: abstract this 2 x 2 layout and reuse
        AvailablePickUpCellView(viewModel: viewModel.cellViewModel)
        
        HStack {
            VStack(alignment: .leading) {
                Text("Estimated Miles: \(viewModel.estimatedMiles)")
                
                Text("Estimated Minutes: \(viewModel.estimatedMinutes)")
            }
            .padding(.leading)
            
            Spacer()
            
            VStack(alignment: .leading) {
                Text("Commute Miles: \(viewModel.commuteMiles)")
                
                Text("Commute Minutes: \(viewModel.commuteMinutes)")
            }
            .padding(.trailing)
            
            
            //TODO: mapkit map with start waypoint lat long
            //TODO: annotation for end waypoint lat long
            //TODO: polyline connecting waypoints
        }
    }
}

//#Preview {
//    
//}
