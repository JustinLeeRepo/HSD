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
    let cellViewModel: AvailablePickUpCellViewModel
    
    init(formatter: NumberFormatter, ride: Ride) {
        self.formatter = formatter
        self.ride = ride
        self.cellViewModel = AvailablePickUpCellViewModel(formatter: formatter, ride: ride)
    }
    
    var score: String {
        return "\(ride.score)"
    }
    
    var estimatedMiles: String {
        return "\(ride.estimatedRideMiles)"
    }
    
    var estimatedMinutes: String {
        return "\(ride.estimatedRideMinutes)"
    }
    
    var commuteMiles: String {
        return "\(ride.commuteRideMiles)"
    }
    
    var commuteMinutes: String {
        return "\(ride.commuteRideMinutes)"
    }
}
