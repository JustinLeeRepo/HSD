//
//  AvailablePickUpCellViewModel.swift
//  HSD
//
//  Created by Justin Lee on 8/26/25.
//

import Foundation

@Observable
class AvailablePickUpCellViewModel {
    let formatter: NumberFormatter
    let ride: Ride
    
    init(formatter: NumberFormatter, ride: Ride) {
        self.formatter = formatter
        self.ride = ride
    }
    
    var estimatedEarnings: String {
        return formatter.string(from: NSNumber(value: ride.estimatedEarnings)) ?? "$0.00"
    }
    
    var startAddress: String? {
        ride.startAddress
    }
    
    var endAddress: String? {
        ride.endAddress
    }
    
    var score: String {
        return "\(ride.score)"
    }
}

extension AvailablePickUpCellViewModel: Identifiable {
    var id: String {
        ride.id
    }
}
