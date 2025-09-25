//
//  AvailablePickUpViewModel.swift
//  HSD
//
//  Created by Justin Lee on 8/26/25.
//

import Combine
import Foundation
import NetworkService
import SwiftUI
import SharedUI

@Observable
class AvailablePickUpViewModel {
    enum State {
        case error(ErrorViewModel)
        case loading
        case success([AvailablePickUpCellViewModel])
        case empty
    }
    
    var state: State {
        if errorViewModel.error != nil {
            return .error(errorViewModel)
        }
        else if isLoading {
            return .loading
        }
        else if !cellViewModels.isEmpty {
            return .success(cellViewModels)
        }
        else {
            return .empty
        }
    }
    
    private var cellViewModels: [AvailablePickUpCellViewModel] = []
    private let errorViewModel: ErrorViewModel
    
    private let availableRideService: AvailableRidesServiceProtocol
    private let numberFormatter: NumberFormatter
    private let availablePickUpEventPublisher: PassthroughSubject<AvailablePickUpEvent, Never>
    
    private var isLoading = false
    
    init(numberFormatter: NumberFormatter, 
         eventPublisher: PassthroughSubject<AvailablePickUpEvent, Never>,
         availableRideService: AvailableRidesServiceProtocol) {
        self.numberFormatter = numberFormatter
        self.availablePickUpEventPublisher = eventPublisher
        self.availableRideService = availableRideService
        self.errorViewModel = ErrorViewModel()
        
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
                self.errorViewModel.error = nil
                isLoading = false
            }
        }
        catch {
            print("error \(error)")
            Task { @MainActor in
                isLoading = false
                self.errorViewModel.error = error
            }
        }
    }
}
