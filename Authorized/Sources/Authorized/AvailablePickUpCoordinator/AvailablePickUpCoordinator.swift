//
//  AvailablePickUpCoordinator.swift
//  HSD
//
//  Created by Justin Lee on 8/27/25.
//

import Combine
import DependencyContainer
import NetworkService
import SwiftUI

enum AvailablePickUpEvent {
    case proceedToDetail(AvailablePickUpDetailViewModel)
}

@Observable
class AvailablePickUpCoordinator {
    var path = NavigationPath()
    
    let availablePickUpViewModel: AvailablePickUpViewModel
    private let numberFormatter: NumberFormatter

    internal let availablePickUpEventPublisher: PassthroughSubject<AvailablePickUpEvent, Never>
    private var cancellables = Set<AnyCancellable>()
    
    init(dependencyContainer: DependencyContainer, eventPublisher: PassthroughSubject<AvailablePickUpEvent, Never>? = nil) {
        let eventPublisher = eventPublisher ?? PassthroughSubject<AvailablePickUpEvent, Never>()
        numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale(identifier: "en_US")
        
        availablePickUpEventPublisher = eventPublisher
        availablePickUpViewModel = AvailablePickUpViewModel(numberFormatter: numberFormatter, eventPublisher: eventPublisher, availableRideService: dependencyContainer.makeAvailableRideService())
        
        setupListener()
    }
    
    private func setupListener() {
        availablePickUpEventPublisher
            .sink { [weak self] event in
                self?.handleNavigationEvent(event)
            }
            .store(in: &cancellables)
    }
    
    private func handleNavigationEvent(_ event: AvailablePickUpEvent) {
        switch event {
        case .proceedToDetail(let viewModel):
            path.append(viewModel)
            break
        }
    }
}
