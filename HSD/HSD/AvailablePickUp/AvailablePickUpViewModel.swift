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
    var cellViewModels: [AvailablePickUpCellViewModel] = []
    var error: Error?
    let numberFormatter: NumberFormatter
    
    init() {
        numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale(identifier: "en_US")
        
        Task {
            await fetchRide()
        }
    }
    
    func fetchRide() async {
        do {
            let rides = try await availableRideService.fetchRides()
            let viewModels = rides.map { AvailablePickUpCellViewModel(formatter: numberFormatter, ride: $0) }
            
            Task { @MainActor in
                self.cellViewModels.append(contentsOf: viewModels)
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
