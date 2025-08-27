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
        HStack {
            VStack(alignment: .leading) {
                Text("Estimated Earnings: \(viewModel.estimatedEarnings)")
                
                Text("Score: \(viewModel.score)")
            }
            .padding(.leading)
            
            Spacer()
            
            VStack(alignment: .leading) {
                if let startAddress = viewModel.startAddress {
                    Text("Pick Up: \(startAddress)")
                }
                
                if let endAddress = viewModel.endAddress {
                    Text("Drop Off: \(endAddress)")
                }
            }
            .padding(.trailing)
        }
    }
}

//#Preview {
//    
//}
