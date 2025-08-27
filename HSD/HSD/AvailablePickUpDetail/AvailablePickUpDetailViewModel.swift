//
//  AvailablePickUpDetailViewModel.swift
//  HSD
//
//  Created by Justin Lee on 8/27/25.
//

import Foundation

@Observable
class AvailablePickUpDetailViewModel: Hashable {
    static func == (lhs: AvailablePickUpDetailViewModel, rhs: AvailablePickUpDetailViewModel) -> Bool {
        lhs.ride.id == rhs.ride.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ride.id)
    }
    
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
