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
    
    private let availableRideService = AvailableRidesService.shared
    private let numberFormatter: NumberFormatter
    private let availablePickUpEventPublisher: PassthroughSubject<AvailablePickUpEvent, Never>
    
    init(numberFormatter: NumberFormatter, eventPublisher: PassthroughSubject<AvailablePickUpEvent, Never>) {
        self.numberFormatter = numberFormatter
        self.availablePickUpEventPublisher = eventPublisher
        
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
