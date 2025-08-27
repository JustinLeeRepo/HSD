//
//  AvailablePickUpViewModel.swift
//  HSD
//
//  Created by Justin Lee on 8/26/25.
//

import Foundation

@Observable
class AvailablePickUpViewModel {
    let availableRideService = AvailableRidesService.shared
    var availableRides: [Ride] = []
    var error: Error?
    
    init() {
        Task {
            await fetchRide()
        }
    }
    
    func fetchRide() async {
        do {
            let rides = try await availableRideService.fetchRides()
            print("rides \(rides)")
            print("yo")
            Task { @MainActor in
                availableRides.append(contentsOf: rides)
            }
        }
        catch {
            print("error \(error)")
            Task { @MainActor in
                self.error = error
            }
        }
    }
}
