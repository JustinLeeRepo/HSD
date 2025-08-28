//
//  AvailablePickUpViewModel.swift
//  HSD
//
//  Created by Justin Lee on 8/26/25.
//

import Combine
import Foundation
import SwiftUI

@Observable
class AvailablePickUpViewModel {
    var cellViewModels: [AvailablePickUpCellViewModel] = []
    var error: Error?
    var isLoading = false
    
    private let availableRideService: AvailableRidesServiceProtocol
    private let numberFormatter: NumberFormatter
    private let availablePickUpEventPublisher: PassthroughSubject<AvailablePickUpEvent, Never>
    
    init(numberFormatter: NumberFormatter, 
         eventPublisher: PassthroughSubject<AvailablePickUpEvent, Never>,
         availableRideService: AvailableRidesServiceProtocol = AvailableRidesService.shared) {
        self.numberFormatter = numberFormatter
        self.availablePickUpEventPublisher = eventPublisher
        self.availableRideService = availableRideService
        
        Task {
            await fetchRide()
        }
    }
    
    func navigateDetail(cellViewModel: AvailablePickUpCellViewModel) {
        let ride = cellViewModel.ride
        let viewModel = AvailablePickUpDetailViewModel(formatter: numberFormatter, ride: ride)
        availablePickUpEventPublisher.send(.proceedToDetail(viewModel))
    }
    
    func fetchRide() async {
        do {
            Task { @MainActor in
                isLoading = true
            }
            
            let rides = try await availableRideService.fetchRides()
            let viewModels = rides
                .sorted { $0.score > $1.score } //!!! NOT PRE SORTED
                .map { AvailablePickUpCellViewModel(formatter: numberFormatter, ride: $0) }
            
            Task { @MainActor in
                self.cellViewModels.append(contentsOf: viewModels)
                isLoading = false
            }
        }
        catch {
            print("error \(error)")
            Task { @MainActor in
                isLoading = false
                self.error = error
            }
        }
    }
}
