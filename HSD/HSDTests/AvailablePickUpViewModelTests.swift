//
//  AvailablePickUpViewModelTests.swift
//  HSDTests
//
//  Created by Justin Lee on 8/27/25.
//

import XCTest

import XCTest
import Combine
import Foundation
@testable import HSD

@MainActor
final class AvailablePickUpViewModelTests: XCTestCase {
    
    var sut: AvailablePickUpViewModel!
    var mockAvailableRidesService: MockAvailableRidesService!
    var numberFormatter: NumberFormatter!
    var eventPublisher: PassthroughSubject<AvailablePickUpEvent, Never>!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        
        // Setup number formatter
        numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.currencyCode = "USD"
        
        // Setup event publisher
        eventPublisher = PassthroughSubject<AvailablePickUpEvent, Never>()
        
        // Setup mock service
        mockAvailableRidesService = MockAvailableRidesService()
        
        // Setup cancellables
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        sut = nil
        mockAvailableRidesService = nil
        numberFormatter = nil
        eventPublisher = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Helper Methods
    
    private func createSUT() {
        sut = AvailablePickUpViewModel(
            numberFormatter: numberFormatter,
            eventPublisher: eventPublisher,
            availableRideService: mockAvailableRidesService
        )
    }
    
    private func createMockRide(
        score: Double = 5.0,
        tripUuid: String = "test-trip-uuid",
        estimatedEarningsCents: Int = 1500
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
            estimatedRideMiles: 10.5,
            estimatedRideMinutes: 30,
            commuteRideMiles: 2.5,
            commuteRideMinutes: 8,
            score: score,
            orderedWaypoints: [startWaypoint, endWaypoint],
            overviewPolyline: "mockPolylineString",
            startsAt: Date(),
            tripUuid: tripUuid,
            uuid: nil
        )
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        createSUT()
        
        XCTAssertNotNil(sut)
        XCTAssertTrue(sut.cellViewModels.isEmpty)
        XCTAssertNil(sut.error)
    }
    
    // MARK: - fetchRide Tests
    
    func testFetchRide_Success() async {
        // Given
        let mockRides = [
            createMockRide(score: 8.5, tripUuid: "ride-1"),
            createMockRide(score: 6.0, tripUuid: "ride-2"),
            createMockRide(score: 9.2, tripUuid: "ride-3")
        ]
        
        mockAvailableRidesService.mockRides = mockRides
        createSUT()
        
        // Wait for initial fetch in init to complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Then
        XCTAssertEqual(sut.cellViewModels.count, 3)
        XCTAssertNil(sut.error)
        
        // Verify rides are sorted by score (descending)
        XCTAssertEqual(sut.cellViewModels[0].ride.score, 9.2)
        XCTAssertEqual(sut.cellViewModels[1].ride.score, 8.5)
        XCTAssertEqual(sut.cellViewModels[2].ride.score, 6.0)
        
        // Verify cell view models are created correctly
        XCTAssertEqual(sut.cellViewModels[0].ride.tripUuid, "ride-3")
        XCTAssertEqual(sut.cellViewModels[1].ride.tripUuid, "ride-1")
        XCTAssertEqual(sut.cellViewModels[2].ride.tripUuid, "ride-2")
    }
    
    func testFetchRide_EmptyResponse() async {
        // Given
        mockAvailableRidesService.mockRides = []
        createSUT()
        
        // Wait for initial fetch in init to complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Then
        XCTAssertTrue(sut.cellViewModels.isEmpty)
        XCTAssertNil(sut.error)
    }
    
    func testFetchRide_Error() async {
        // Given
        let expectedError = ServiceError.unauthorized
        mockAvailableRidesService.shouldThrowError = true
        mockAvailableRidesService.errorToThrow = expectedError
        
        createSUT()
        
        // Wait for initial fetch in init to complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Then
        XCTAssertTrue(sut.cellViewModels.isEmpty)
        XCTAssertNotNil(sut.error)
        XCTAssertEqual(sut.error as? ServiceError, expectedError)
    }
    
    func testFetchRide_ManualCall() async {
        // Given
        let mockRides = [createMockRide(score: 7.5, tripUuid: "manual-ride")]
        mockAvailableRidesService.mockRides = mockRides
        createSUT()
        
        // Wait for initial fetch to complete
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Clear existing results
        sut.cellViewModels.removeAll()
        
        // When
        await sut.fetchRide()
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then
        XCTAssertEqual(sut.cellViewModels.count, 1)
        XCTAssertEqual(sut.cellViewModels[0].ride.tripUuid, "manual-ride")
        XCTAssertNil(sut.error)
    }
    
    func testFetchRide_SortingBehavior() async {
        // Given
        let mockRides = [
            createMockRide(score: 3.5, tripUuid: "low-score"),
            createMockRide(score: 10.0, tripUuid: "high-score"),
            createMockRide(score: 7.2, tripUuid: "mid-score"),
            createMockRide(score: 1.0, tripUuid: "lowest-score"),
            createMockRide(score: 8.8, tripUuid: "another-high")
        ]
        
        mockAvailableRidesService.mockRides = mockRides
        createSUT()
        
        // Wait for initial fetch in init to complete
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        // Then - verify proper descending sort by score
        let sortedScores = sut.cellViewModels.map { $0.ride.score }
        XCTAssertEqual(sortedScores, [10.0, 8.8, 7.2, 3.5, 1.0])
        
        let sortedUuids = sut.cellViewModels.map { $0.ride.tripUuid }
        XCTAssertEqual(sortedUuids, ["high-score", "another-high", "mid-score", "low-score", "lowest-score"])
    }
    
    // MARK: - navigateDetail Tests
    
    func testNavigateDetail() {
        // Given
        let mockRide = createMockRide(tripUuid: "detail-ride")
        let cellViewModel = AvailablePickUpCellViewModel(formatter: numberFormatter, ride: mockRide)
        
        var receivedEvent: AvailablePickUpEvent?
        eventPublisher
            .sink { event in
                receivedEvent = event
            }
            .store(in: &cancellables)
        
        createSUT()
        
        // When
        sut.navigateDetail(cellViewModel: cellViewModel)
        
        // Then
        XCTAssertNotNil(receivedEvent)
        
        if case let .proceedToDetail(detailViewModel) = receivedEvent {
            XCTAssertEqual(detailViewModel.ride.tripUuid, "detail-ride")
            XCTAssertEqual(detailViewModel.ride.id, mockRide.id)
        } else {
            XCTFail("Expected proceedToDetail event")
        }
    }
    
    func testNavigateDetail_WithDifferentRides() {
        // Given
        let ride1 = createMockRide(tripUuid: "ride-1", estimatedEarningsCents: 1200)
        let ride2 = createMockRide(tripUuid: "ride-2", estimatedEarningsCents: 2500)
        
        let cellViewModel1 = AvailablePickUpCellViewModel(formatter: numberFormatter, ride: ride1)
        let cellViewModel2 = AvailablePickUpCellViewModel(formatter: numberFormatter, ride: ride2)
        
        var receivedEvents: [AvailablePickUpEvent] = []
        eventPublisher
            .sink { event in
                receivedEvents.append(event)
            }
            .store(in: &cancellables)
        
        createSUT()
        
        // When
        sut.navigateDetail(cellViewModel: cellViewModel1)
        sut.navigateDetail(cellViewModel: cellViewModel2)
        
        // Then
        XCTAssertEqual(receivedEvents.count, 2)
        
        if case let .proceedToDetail(detailViewModel1) = receivedEvents[0] {
            XCTAssertEqual(detailViewModel1.ride.tripUuid, "ride-1")
            XCTAssertEqual(detailViewModel1.ride.estimatedEarningsCents, 1200)
        } else {
            XCTFail("Expected first proceedToDetail event")
        }
        
        if case let .proceedToDetail(detailViewModel2) = receivedEvents[1] {
            XCTAssertEqual(detailViewModel2.ride.tripUuid, "ride-2")
            XCTAssertEqual(detailViewModel2.ride.estimatedEarningsCents, 2500)
        } else {
            XCTFail("Expected second proceedToDetail event")
        }
    }
}

// MARK: - Mock Classes

class MockAvailableRidesService: AvailableRidesServiceProtocol {
    var mockRides: [Ride] = []
    var shouldThrowError = false
    var errorToThrow: Error = ServiceError.noData
    var fetchRidesCallCount = 0
    var fetchRidesPageCallCount = 0
    
    func fetchRides() async throws -> [Ride] {
        fetchRidesCallCount += 1
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        return mockRides
    }
    
    func fetchRidesPage(pageSize: Int?) async throws -> [Ride] {
        fetchRidesPageCallCount += 1
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        return mockRides
    }
    
    func reset() {
        mockRides = []
        shouldThrowError = false
        errorToThrow = ServiceError.noData
        fetchRidesCallCount = 0
        fetchRidesPageCallCount = 0
    }
}
