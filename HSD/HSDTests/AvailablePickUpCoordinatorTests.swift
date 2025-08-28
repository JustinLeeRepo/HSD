//
//  AvailablePickUpCoordinatorTests.swift
//  HSDTests
//
//  Created by Justin Lee on 8/28/25.
//

import XCTest
import Combine
import SwiftUI
@testable import HSD

final class AvailablePickUpCoordinatorTests: XCTestCase {
    
    var sut: AvailablePickUpCoordinator!
    var mockEventPublisher: PassthroughSubject<AvailablePickUpEvent, Never>!
    var cancellables: Set<AnyCancellable>!
    var mockNumberFormatter: NumberFormatter!
    var mockRide: Ride!
    
    override func setUp() {
        super.setUp()
        mockNumberFormatter = NumberFormatter()
        mockNumberFormatter.numberStyle = .currency
        mockNumberFormatter.locale = Locale(identifier: "en_US")
        
        mockRide = createMockRide()
        mockEventPublisher = PassthroughSubject<AvailablePickUpEvent, Never>()
        
        // Create coordinator with mocked dependencies
        sut = AvailablePickUpCoordinator(eventPublisher: mockEventPublisher)
        
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        sut = nil
        mockEventPublisher = nil
        cancellables = nil
        mockNumberFormatter = nil
        mockRide = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInit_ShouldInitializeWithEmptyNavigationPath() {
        // Given & When
        let coordinator = AvailablePickUpCoordinator()
        
        // Then
        XCTAssertTrue(coordinator.path.isEmpty)
    }
    
    func testInit_ShouldCreateAvailablePickUpViewModel() {
        // Given & When
        let coordinator = AvailablePickUpCoordinator()
        
        // Then
        XCTAssertNotNil(coordinator.availablePickUpViewModel)
    }
    
    // MARK: - Navigation Event Handling Tests
    
    func testEventPublisher_WithProceedToDetailEvent_ShouldAppendToPath() {
        // Given
        let detailViewModel = AvailablePickUpDetailViewModel(
            formatter: mockNumberFormatter,
            ride: mockRide
        )
        let event = AvailablePickUpEvent.proceedToDetail(detailViewModel)
        let initialPathCount = sut.path.count
        
        let expectation = XCTestExpectation(description: "Navigation path should be updated")
        
        // When
        mockEventPublisher.send(event)
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.sut.path.count, initialPathCount + 1)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testEventPublisher_WithMultipleProceedToDetailEvents_ShouldAppendMultipleItemsToPath() {
        // Given
        let detailViewModel1 = AvailablePickUpDetailViewModel(
            formatter: mockNumberFormatter,
            ride: mockRide
        )
        let detailViewModel2 = AvailablePickUpDetailViewModel(
            formatter: mockNumberFormatter,
            ride: createMockRide(id: "ride2")
        )
        let event1 = AvailablePickUpEvent.proceedToDetail(detailViewModel1)
        let event2 = AvailablePickUpEvent.proceedToDetail(detailViewModel2)
        
        let expectation = XCTestExpectation(description: "Both navigation events should be processed")
        
        // When
        mockEventPublisher.send(event1)
        mockEventPublisher.send(event2)
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.sut.path.count, 2)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testEventPublisher_WithRapidEvents_ShouldHandleAllEvents() {
        // Given
        let events = (0..<5).map { index in
            let detailViewModel = AvailablePickUpDetailViewModel(
                formatter: mockNumberFormatter,
                ride: createMockRide(id: "ride\(index)")
            )
            return AvailablePickUpEvent.proceedToDetail(detailViewModel)
        }
        
        let expectation = XCTestExpectation(description: "All rapid events should be processed")
        
        // When
        events.forEach { event in
            mockEventPublisher.send(event)
        }
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertEqual(self.sut.path.count, 5)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Event Publisher Completion Tests
    
    func testEventPublisher_WhenCompleted_ShouldNotCrash() {
        // Given
        let detailViewModel = AvailablePickUpDetailViewModel(
            formatter: mockNumberFormatter,
            ride: mockRide
        )
        let event = AvailablePickUpEvent.proceedToDetail(detailViewModel)
        
        // When
        mockEventPublisher.send(event)
        mockEventPublisher.send(completion: .finished)
        
        // Then
        // Should not crash and path should still contain the item
        XCTAssertEqual(sut.path.count, 1)
    }
    
    // MARK: - Subscription Management Tests
    
    func testCoordinator_ShouldMaintainSubscriptionThroughMultipleEvents() {
        // Given
        let events = (0..<3).map { index in
            let detailViewModel = AvailablePickUpDetailViewModel(
                formatter: mockNumberFormatter,
                ride: createMockRide(id: "ride\(index)")
            )
            return AvailablePickUpEvent.proceedToDetail(detailViewModel)
        }
        
        let expectation = XCTestExpectation(description: "Subscription should remain active")
        
        // When
        events.enumerated().forEach { (index, event) in
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                self.mockEventPublisher.send(event)
            }
        }
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(self.sut.path.count, 3)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Observable Behavior Tests
    
    func testPath_ShouldBeObservableWhenTriggeredViaPublisher() {
        // Given
        var pathChangeCount = 0
        let expectation = XCTestExpectation(description: "Path changes should be observable")
        
        // Observe path changes (in a real app, SwiftUI would do this automatically)
        let pathObserver = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            pathChangeCount += 1
        }
        
        // When
        let detailViewModel = AvailablePickUpDetailViewModel(
            formatter: mockNumberFormatter,
            ride: mockRide
        )
        let event = AvailablePickUpEvent.proceedToDetail(detailViewModel)
        mockEventPublisher.send(event)
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            pathObserver.invalidate()
            XCTAssertTrue(self.sut.path.count > 0)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    
    private func createMockRide(
        id: String = "testRideId",
        score: Double = 75.0,
        estimatedEarningsCents: Int = 1000,
        estimatedRideMiles: Double = 10.0,
        estimatedRideMinutes: Int = 20,
        commuteRideMiles: Double = 8.5,
        commuteRideMinutes: Int = 15
    ) -> Ride {
        let startWaypoint = Waypoint(
            id: 1,
            location: Location(address: "123 Start St", lat: 37.7749, lng: -122.4194),
            waypointType: .pickUp
        )
        
        let endWaypoint = Waypoint(
            id: 2,
            location: Location(address: "456 End St", lat: 37.7849, lng: -122.4094),
            waypointType: .dropOff
        )
        
        return Ride(
            endsAt: Date().addingTimeInterval(3600), // 1 hour from now
            estimatedEarningsCents: estimatedEarningsCents,
            estimatedRideMiles: estimatedRideMiles,
            estimatedRideMinutes: estimatedRideMinutes,
            commuteRideMiles: commuteRideMiles,
            commuteRideMinutes: commuteRideMinutes,
            score: score,
            orderedWaypoints: [startWaypoint, endWaypoint],
            overviewPolyline: "mockPolylineString",
            startsAt: Date(),
            tripUuid: "tripUuid",
            uuid: nil
        )
    }
}


// MARK: - Additional Test Cases

extension AvailablePickUpCoordinatorTests {
    
    func testEventPublisher_WithBackToBackEvents_ShouldHandleCorrectly() {
        // Given
        let detailViewModel1 = AvailablePickUpDetailViewModel(
            formatter: mockNumberFormatter,
            ride: createMockRide(id: "ride1")
        )
        let detailViewModel2 = AvailablePickUpDetailViewModel(
            formatter: mockNumberFormatter,
            ride: createMockRide(id: "ride2")
        )
        
        let expectation = XCTestExpectation(description: "Back-to-back events should be handled")
        
        // When
        mockEventPublisher.send(.proceedToDetail(detailViewModel1))
        mockEventPublisher.send(.proceedToDetail(detailViewModel2))
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.sut.path.count, 2)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testPath_ShouldSupportNavigationOperationsAfterPublisherEvents() {
        // Given
        let detailViewModel = AvailablePickUpDetailViewModel(
            formatter: mockNumberFormatter,
            ride: mockRide
        )
        let event = AvailablePickUpEvent.proceedToDetail(detailViewModel)
        
        let expectation1 = XCTestExpectation(description: "Event should add item to path")
        
        // When - Add item via publisher
        mockEventPublisher.send(event)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.sut.path.count, 1)
            expectation1.fulfill()
        }
        wait(for: [expectation1], timeout: 1.0)
        
        // When - Remove item (simulate back navigation)
        sut.path.removeLast()
        
        // Then
        XCTAssertEqual(sut.path.count, 0)
    }
}
