//
//  AvailablePickUpDetailViewModelTests.swift
//  HSDTests
//
//  Created by Justin Lee on 8/27/25.
//

import XCTest
import Foundation
@testable import HSD

final class AvailablePickUpDetailViewModelTests: XCTestCase {
    
    var sut: AvailablePickUpDetailViewModel!
    var numberFormatter: NumberFormatter!
    var mockRide: Ride!
    
    override func setUp() {
        super.setUp()
        
        // Setup number formatter with consistent settings
        numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.currencyCode = "USD"
        numberFormatter.locale = Locale(identifier: "en_US")
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
    }
    
    override func tearDown() {
        sut = nil
        numberFormatter = nil
        mockRide = nil
        super.tearDown()
    }
    
    // MARK: - Helper Methods
    
    private func createMockRide(
        estimatedEarningsCents: Int = 2500,
        estimatedRideMiles: Double = 15.5,
        estimatedRideMinutes: Int = 45,
        commuteRideMiles: Double = 3.2,
        commuteRideMinutes: Int = 12,
        score: Double = 8.7,
        tripUuid: String = "test-detail-uuid",
        startAddress: String? = "123 Detail Start St",
        endAddress: String? = "456 Detail End Ave",
        overviewPolyline: String = "detailPolylineString"
    ) -> Ride {
        let startWaypoint = Waypoint(
            id: 10,
            location: Location(address: startAddress ?? "Unknown Start", lat: 37.7749, lng: -122.4194),
            waypointType: .pickUp
        )
        
        let endWaypoint = Waypoint(
            id: 20,
            location: Location(address: endAddress ?? "Unknown End", lat: 37.7849, lng: -122.4094),
            waypointType: .dropOff
        )
        
        return Ride(
            endsAt: Date().addingTimeInterval(2700), // 45 minutes from now
            estimatedEarningsCents: estimatedEarningsCents,
            estimatedRideMiles: estimatedRideMiles,
            estimatedRideMinutes: estimatedRideMinutes,
            commuteRideMiles: commuteRideMiles,
            commuteRideMinutes: commuteRideMinutes,
            score: score,
            orderedWaypoints: [startWaypoint, endWaypoint],
            overviewPolyline: overviewPolyline,
            startsAt: Date(),
            tripUuid: tripUuid,
            uuid: nil
        )
    }
    
    private func createSUT(with ride: Ride? = nil) {
        let testRide = ride ?? createMockRide()
        sut = AvailablePickUpDetailViewModel(formatter: numberFormatter, ride: testRide)
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        // Given
        let ride = createMockRide(
            estimatedEarningsCents: 3000,
            tripUuid: "init-test-uuid",
            overviewPolyline: "initPolyline"
        )
        
        // When
        createSUT(with: ride)
        
        // Then
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.formatter, numberFormatter)
        XCTAssertEqual(sut.ride.id, ride.id)
        XCTAssertEqual(sut.ride.tripUuid, "init-test-uuid")
        XCTAssertNotNil(sut.cellViewModel)
        XCTAssertNotNil(sut.routeViewModel)
    }
    
    func testInitialization_CellViewModelCreation() {
        // Given
        let ride = createMockRide(estimatedEarningsCents: 1800)
        
        // When
        createSUT(with: ride)
        
        // Then
        XCTAssertEqual(sut.cellViewModel.ride.id, ride.id)
        XCTAssertEqual(sut.cellViewModel.formatter, numberFormatter)
        XCTAssertEqual(sut.cellViewModel.estimatedEarnings, "$18.00")
    }
    
    func testInitialization_RouteViewModelCreation() {
        // Given
        let customPolyline = "customRoutePolyline"
        let customStartTime = Date()
        let customEndTime = customStartTime.addingTimeInterval(3600)
        
        let ride = Ride(
            endsAt: customEndTime,
            estimatedEarningsCents: 2000,
            estimatedRideMiles: 10.0,
            estimatedRideMinutes: 30,
            commuteRideMiles: 2.0,
            commuteRideMinutes: 5,
            score: 7.5,
            orderedWaypoints: [
                Waypoint(id: 1, location: Location(address: "Start", lat: 37.7749, lng: -122.4194), waypointType: .pickUp),
                Waypoint(id: 2, location: Location(address: "End", lat: 37.7849, lng: -122.4094), waypointType: .dropOff)
            ],
            overviewPolyline: customPolyline,
            startsAt: customStartTime,
            tripUuid: "route-test-uuid",
            uuid: nil
        )
        
        // When
        createSUT(with: ride)
        
        // Then
        XCTAssertEqual(sut.routeViewModel.overviewPolyline, customPolyline)
        XCTAssertEqual(sut.routeViewModel.wayPoints.count, 2)
        XCTAssertEqual(sut.routeViewModel.startTime, customStartTime)
        XCTAssertEqual(sut.routeViewModel.endTime, customEndTime)
    }
    
    // MARK: - Score Tests
    
    func testScore_IntegerValue() {
        // Given
        let ride = createMockRide(score: 9.0)
        createSUT(with: ride)
        
        // When
        let score = sut.score
        
        // Then
        XCTAssertEqual(score, "9.0")
    }
    
    func testScore_DecimalValue() {
        // Given
        let ride = createMockRide(score: 7.85)
        createSUT(with: ride)
        
        // When
        let score = sut.score
        
        // Then
        XCTAssertEqual(score, "7.85")
    }
    
    func testScore_ZeroValue() {
        // Given
        let ride = createMockRide(score: 0.0)
        createSUT(with: ride)
        
        // When
        let score = sut.score
        
        // Then
        XCTAssertEqual(score, "0.0")
    }
    
    func testScore_NegativeValue() {
        // Given
        let ride = createMockRide(score: -1.5)
        createSUT(with: ride)
        
        // When
        let score = sut.score
        
        // Then
        XCTAssertEqual(score, "-1.5")
    }
    
    func testScore_HighPrecisionValue() {
        // Given
        let ride = createMockRide(score: 8.123456789)
        createSUT(with: ride)
        
        // When
        let score = sut.score
        
        // Then
        XCTAssertEqual(score, "8.123456789")
    }
    
    // MARK: - Estimated Miles Tests
    
    func testEstimatedMiles_IntegerValue() {
        // Given
        let ride = createMockRide(estimatedRideMiles: 20.0)
        createSUT(with: ride)
        
        // When
        let miles = sut.estimatedMiles
        
        // Then
        XCTAssertEqual(miles, "20.0")
    }
    
    func testEstimatedMiles_DecimalValue() {
        // Given
        let ride = createMockRide(estimatedRideMiles: 15.75)
        createSUT(with: ride)
        
        // When
        let miles = sut.estimatedMiles
        
        // Then
        XCTAssertEqual(miles, "15.75")
    }
    
    func testEstimatedMiles_ZeroValue() {
        // Given
        let ride = createMockRide(estimatedRideMiles: 0.0)
        createSUT(with: ride)
        
        // When
        let miles = sut.estimatedMiles
        
        // Then
        XCTAssertEqual(miles, "0.0")
    }
    
    func testEstimatedMiles_SmallDecimal() {
        // Given
        let ride = createMockRide(estimatedRideMiles: 0.1)
        createSUT(with: ride)
        
        // When
        let miles = sut.estimatedMiles
        
        // Then
        XCTAssertEqual(miles, "0.1")
    }
    
    // MARK: - Estimated Minutes Tests
    
    func testEstimatedMinutes_TypicalValue() {
        // Given
        let ride = createMockRide(estimatedRideMinutes: 30)
        createSUT(with: ride)
        
        // When
        let minutes = sut.estimatedMinutes
        
        // Then
        XCTAssertEqual(minutes, "30")
    }
    
    func testEstimatedMinutes_ZeroValue() {
        // Given
        let ride = createMockRide(estimatedRideMinutes: 0)
        createSUT(with: ride)
        
        // When
        let minutes = sut.estimatedMinutes
        
        // Then
        XCTAssertEqual(minutes, "0")
    }
    
    func testEstimatedMinutes_LargeValue() {
        // Given
        let ride = createMockRide(estimatedRideMinutes: 120)
        createSUT(with: ride)
        
        // When
        let minutes = sut.estimatedMinutes
        
        // Then
        XCTAssertEqual(minutes, "120")
    }
    
    // MARK: - Commute Miles Tests
    
    func testCommuteMiles_TypicalValue() {
        // Given
        let ride = createMockRide(commuteRideMiles: 5.25)
        createSUT(with: ride)
        
        // When
        let miles = sut.commuteMiles
        
        // Then
        XCTAssertEqual(miles, "5.25")
    }
    
    func testCommuteMiles_ZeroValue() {
        // Given
        let ride = createMockRide(commuteRideMiles: 0.0)
        createSUT(with: ride)
        
        // When
        let miles = sut.commuteMiles
        
        // Then
        XCTAssertEqual(miles, "0.0")
    }
    
    func testCommuteMiles_HighPrecisionValue() {
        // Given
        let ride = createMockRide(commuteRideMiles: 2.123456)
        createSUT(with: ride)
        
        // When
        let miles = sut.commuteMiles
        
        // Then
        XCTAssertEqual(miles, "2.123456")
    }
    
    // MARK: - Commute Minutes Tests
    
    func testCommuteMinutes_TypicalValue() {
        // Given
        let ride = createMockRide(commuteRideMinutes: 8)
        createSUT(with: ride)
        
        // When
        let minutes = sut.commuteMinutes
        
        // Then
        XCTAssertEqual(minutes, "8")
    }
    
    func testCommuteMinutes_ZeroValue() {
        // Given
        let ride = createMockRide(commuteRideMinutes: 0)
        createSUT(with: ride)
        
        // When
        let minutes = sut.commuteMinutes
        
        // Then
        XCTAssertEqual(minutes, "0")
    }
    
    func testCommuteMinutes_LargeValue() {
        // Given
        let ride = createMockRide(commuteRideMinutes: 45)
        createSUT(with: ride)
        
        // When
        let minutes = sut.commuteMinutes
        
        // Then
        XCTAssertEqual(minutes, "45")
    }
    
    // MARK: - Hashable Tests
    
    func testHashable_EqualViewModels() {
        // Given
        let ride1 = createMockRide(tripUuid: "same-uuid")
        let ride2 = createMockRide(tripUuid: "same-uuid") // Same UUID, different properties
        
        let viewModel1 = AvailablePickUpDetailViewModel(formatter: numberFormatter, ride: ride1)
        let viewModel2 = AvailablePickUpDetailViewModel(formatter: numberFormatter, ride: ride2)
        
        // When & Then
        XCTAssertEqual(viewModel1, viewModel2)
        XCTAssertEqual(viewModel1.hashValue, viewModel2.hashValue)
    }
    
    func testHashable_DifferentViewModels() {
        // Given
        let ride1 = createMockRide(tripUuid: "uuid-1")
        let ride2 = createMockRide(tripUuid: "uuid-2")
        
        let viewModel1 = AvailablePickUpDetailViewModel(formatter: numberFormatter, ride: ride1)
        let viewModel2 = AvailablePickUpDetailViewModel(formatter: numberFormatter, ride: ride2)
        
        // When & Then
        XCTAssertNotEqual(viewModel1, viewModel2)
        XCTAssertNotEqual(viewModel1.hashValue, viewModel2.hashValue)
    }
    
    func testHashable_SameViewModelInstance() {
        // Given
        let ride = createMockRide()
        createSUT(with: ride)
        
        // When & Then
        XCTAssertEqual(sut, sut)
        XCTAssertEqual(sut.hashValue, sut.hashValue)
    }
    
    func testHashable_SetUsage() {
        // Given
        let ride1 = createMockRide(tripUuid: "set-test-1")
        let ride2 = createMockRide(tripUuid: "set-test-2")
        let ride3 = createMockRide(tripUuid: "set-test-1") // Duplicate UUID
        
        let viewModel1 = AvailablePickUpDetailViewModel(formatter: numberFormatter, ride: ride1)
        let viewModel2 = AvailablePickUpDetailViewModel(formatter: numberFormatter, ride: ride2)
        let viewModel3 = AvailablePickUpDetailViewModel(formatter: numberFormatter, ride: ride3)
        
        // When
        let viewModelSet: Set<AvailablePickUpDetailViewModel> = [viewModel1, viewModel2, viewModel3]
        
        // Then
        XCTAssertEqual(viewModelSet.count, 2) // viewModel1 and viewModel3 should be treated as same
        XCTAssertTrue(viewModelSet.contains(viewModel1))
        XCTAssertTrue(viewModelSet.contains(viewModel2))
        XCTAssertTrue(viewModelSet.contains(viewModel3)) // Same as viewModel1
    }
    
    // MARK: - Integration Tests
    
    func testCompleteViewModel_AllProperties() {
        // Given
        let ride = createMockRide(
            estimatedEarningsCents: 4500, // $45.00
            estimatedRideMiles: 25.75,
            estimatedRideMinutes: 60,
            commuteRideMiles: 4.25,
            commuteRideMinutes: 15,
            score: 9.2,
            tripUuid: "integration-test-uuid"
        )
        
        // When
        createSUT(with: ride)
        
        // Then - Test all computed properties
        XCTAssertEqual(sut.score, "9.2")
        XCTAssertEqual(sut.estimatedMiles, "25.75")
        XCTAssertEqual(sut.estimatedMinutes, "60")
        XCTAssertEqual(sut.commuteMiles, "4.25")
        XCTAssertEqual(sut.commuteMinutes, "15")
        
        // Test embedded view models
        XCTAssertEqual(sut.cellViewModel.estimatedEarnings, "$45.00")
        XCTAssertEqual(sut.routeViewModel.wayPoints.count, 2)
        
        // Test ride reference
        XCTAssertEqual(sut.ride.id, ride.id)
        XCTAssertEqual(sut.ride.tripUuid, "integration-test-uuid")
    }
    
    func testMultipleViewModels_DifferentFormatters() {
        // Given
        let euroFormatter = NumberFormatter()
        euroFormatter.numberStyle = .currency
        euroFormatter.currencyCode = "EUR"
        euroFormatter.locale = Locale(identifier: "de_DE")
        
        let ride1 = createMockRide(estimatedEarningsCents: 2000)
        let ride2 = createMockRide(estimatedEarningsCents: 2000)
        
        let usdViewModel = AvailablePickUpDetailViewModel(formatter: numberFormatter, ride: ride1)
        let eurViewModel = AvailablePickUpDetailViewModel(formatter: euroFormatter, ride: ride2)
        
        // When & Then
        XCTAssertTrue(usdViewModel.cellViewModel.estimatedEarnings.contains("$"))
        XCTAssertTrue(eurViewModel.cellViewModel.estimatedEarnings.contains("€") ||
                     eurViewModel.cellViewModel.estimatedEarnings.contains("EUR"))
        
        // Non-currency properties should be identical
        XCTAssertEqual(usdViewModel.score, eurViewModel.score)
        XCTAssertEqual(usdViewModel.estimatedMiles, eurViewModel.estimatedMiles)
        XCTAssertEqual(usdViewModel.estimatedMinutes, eurViewModel.estimatedMinutes)
    }
    
    // MARK: - Edge Cases
    
    func testRideWithNoWaypoints() {
        // Given
        let rideWithNoWaypoints = Ride(
            endsAt: Date().addingTimeInterval(3600),
            estimatedEarningsCents: 3000,
            estimatedRideMiles: 12.5,
            estimatedRideMinutes: 35,
            commuteRideMiles: 2.5,
            commuteRideMinutes: 8,
            score: 6.8,
            orderedWaypoints: [], // No waypoints
            overviewPolyline: "emptyPolyline",
            startsAt: Date(),
            tripUuid: "no-waypoints-uuid",
            uuid: nil
        )
        
        // When
        createSUT(with: rideWithNoWaypoints)
        
        // Then
        XCTAssertEqual(sut.score, "6.8")
        XCTAssertEqual(sut.estimatedMiles, "12.5")
        XCTAssertEqual(sut.estimatedMinutes, "35")
        XCTAssertEqual(sut.commuteMiles, "2.5")
        XCTAssertEqual(sut.commuteMinutes, "8")
        
        // Route view model should handle empty waypoints
        XCTAssertEqual(sut.routeViewModel.wayPoints.count, 0)
        XCTAssertEqual(sut.routeViewModel.overviewPolyline, "emptyPolyline")
        
        // Cell view model should handle missing addresses
        XCTAssertNil(sut.cellViewModel.startAddress)
        XCTAssertNil(sut.cellViewModel.endAddress)
    }
    
    func testExtremeValues() {
        // Given
        let extremeRide = createMockRide(
            estimatedRideMiles: 999.99,
            estimatedRideMinutes: 9999,
            commuteRideMiles: 0.001,
            commuteRideMinutes: 1,
            score: -999.999
        )
        
        // When
        createSUT(with: extremeRide)
        
        // Then
        XCTAssertEqual(sut.estimatedMiles, "999.99")
        XCTAssertEqual(sut.estimatedMinutes, "9999")
        XCTAssertEqual(sut.commuteMiles, "0.001")
        XCTAssertEqual(sut.commuteMinutes, "1")
        XCTAssertEqual(sut.score, "-999.999")
    }
    
    // MARK: - Memory and Performance Tests
    
    func testViewModelRetention() {
        // Given
        let ride = createMockRide()
        
        // When
        weak var weakViewModel: AvailablePickUpDetailViewModel?
        
        autoreleasepool {
            let viewModel = AvailablePickUpDetailViewModel(formatter: numberFormatter, ride: ride)
            weakViewModel = viewModel
            XCTAssertNotNil(weakViewModel)
            // viewModel should be deallocated when leaving this scope
        }
        
        // Then
        XCTAssertNil(weakViewModel, "ViewModel should be deallocated")
    }
}
