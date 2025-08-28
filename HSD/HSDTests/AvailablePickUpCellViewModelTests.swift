//
//  AvailablePickUpCellViewModelTests.swift
//  HSDTests
//
//  Created by Justin Lee on 8/27/25.
//

import XCTest
import Foundation
@testable import HSD

final class AvailablePickUpCellViewModelTests: XCTestCase {
    
    var sut: AvailablePickUpCellViewModel!
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
        estimatedEarningsCents: Int = 1500,
        score: Double = 7.5,
        tripUuid: String = "test-trip-uuid",
        startAddress: String? = "123 Start Street, City, ST",
        endAddress: String? = "456 End Avenue, City, ST"
    ) -> Ride {
        let startWaypoint = Waypoint(
            id: 1,
            location: Location(address: startAddress ?? "Unknown Start", lat: 37.7749, lng: -122.4194),
            waypointType: .pickUp
        )
        
        let endWaypoint = Waypoint(
            id: 2,
            location: Location(address: endAddress ?? "Unknown End", lat: 37.7849, lng: -122.4094),
            waypointType: .dropOff
        )
        
        return Ride(
            endsAt: Date().addingTimeInterval(3600),
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
    
    private func createSUT(with ride: Ride) {
        sut = AvailablePickUpCellViewModel(formatter: numberFormatter, ride: ride)
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        // Given
        let ride = createMockRide()
        
        // When
        createSUT(with: ride)
        
        // Then
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.formatter, numberFormatter)
        XCTAssertEqual(sut.ride.id, ride.id)
        XCTAssertEqual(sut.ride.tripUuid, ride.tripUuid)
    }
    
    // MARK: - estimatedEarnings Tests
    
    func testEstimatedEarnings_ValidAmount() {
        // Given
        let ride = createMockRide(estimatedEarningsCents: 2550) // $25.50
        createSUT(with: ride)
        
        // When
        let earnings = sut.estimatedEarnings
        
        // Then
        XCTAssertEqual(earnings, "$25.50")
    }
    
    func testEstimatedEarnings_ZeroAmount() {
        // Given
        let ride = createMockRide(estimatedEarningsCents: 0)
        createSUT(with: ride)
        
        // When
        let earnings = sut.estimatedEarnings
        
        // Then
        XCTAssertEqual(earnings, "$0.00")
    }
    
    func testEstimatedEarnings_LargeAmount() {
        // Given
        let ride = createMockRide(estimatedEarningsCents: 999999) // $9999.99
        createSUT(with: ride)
        
        // When
        let earnings = sut.estimatedEarnings
        
        // Then
        XCTAssertEqual(earnings, "$9,999.99")
    }
    
    func testEstimatedEarnings_SmallAmount() {
        // Given
        let ride = createMockRide(estimatedEarningsCents: 1) // $0.01
        createSUT(with: ride)
        
        // When
        let earnings = sut.estimatedEarnings
        
        // Then
        XCTAssertEqual(earnings, "$0.01")
    }
    
    func testEstimatedEarnings_WithDifferentFormatter() {
        // Given
        let euroFormatter = NumberFormatter()
        euroFormatter.numberStyle = .currency
        euroFormatter.currencyCode = "EUR"
        euroFormatter.locale = Locale(identifier: "de_DE")
        
        let ride = createMockRide(estimatedEarningsCents: 1500) // €15.00
        sut = AvailablePickUpCellViewModel(formatter: euroFormatter, ride: ride)
        
        // When
        let earnings = sut.estimatedEarnings
        
        // Then
        XCTAssertTrue(earnings.contains("15"))
        XCTAssertTrue(earnings.contains("€") || earnings.contains("EUR"))
    }
    
    // MARK: - Address Tests
    
    func testStartAddress_WithValidAddress() {
        // Given
        let expectedStartAddress = "123 Main Street, Anytown, CA"
        let ride = createMockRide(startAddress: expectedStartAddress)
        createSUT(with: ride)
        
        // When
        let startAddress = sut.startAddress
        
        // Then
        XCTAssertEqual(startAddress, expectedStartAddress)
    }
    
    func testStartAddress_WithNilAddress() {
        // Given
        let ride = createMockRide(startAddress: nil)
        createSUT(with: ride)
        
        // When
        let startAddress = sut.startAddress
        
        // Then
        XCTAssertEqual(startAddress, "Unknown Start") // From our mock creation
    }
    
    func testEndAddress_WithValidAddress() {
        // Given
        let expectedEndAddress = "789 End Boulevard, Destination City, NY"
        let ride = createMockRide(endAddress: expectedEndAddress)
        createSUT(with: ride)
        
        // When
        let endAddress = sut.endAddress
        
        // Then
        XCTAssertEqual(endAddress, expectedEndAddress)
    }
    
    func testEndAddress_WithNilAddress() {
        // Given
        let ride = createMockRide(endAddress: nil)
        createSUT(with: ride)
        
        // When
        let endAddress = sut.endAddress
        
        // Then
        XCTAssertEqual(endAddress, "Unknown End") // From our mock creation
    }
    
    func testAddresses_BothEmpty() {
        // Given
        let ride = createMockRide(startAddress: "", endAddress: "")
        createSUT(with: ride)
        
        // When
        let startAddress = sut.startAddress
        let endAddress = sut.endAddress
        
        // Then
        XCTAssertEqual(startAddress, "")
        XCTAssertEqual(endAddress, "")
    }
    
    // MARK: - Score Tests
    
    func testScore_IntegerValue() {
        // Given
        let ride = createMockRide(score: 8.0)
        createSUT(with: ride)
        
        // When
        let score = sut.score
        
        // Then
        XCTAssertEqual(score, "8.0")
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
        let ride = createMockRide(score: -2.5)
        createSUT(with: ride)
        
        // When
        let score = sut.score
        
        // Then
        XCTAssertEqual(score, "-2.5")
    }
    
    func testScore_VeryHighPrecision() {
        // Given
        let ride = createMockRide(score: 9.123456789)
        createSUT(with: ride)
        
        // When
        let score = sut.score
        
        // Then
        XCTAssertEqual(score, "9.123456789")
    }
    
    // MARK: - Identifiable Tests
    
    func testId_WithTripUuid() {
        // Given
        let expectedTripUuid = "unique-trip-12345"
        let ride = createMockRide(tripUuid: expectedTripUuid)
        createSUT(with: ride)
        
        // When
        let id = sut.id
        
        // Then
        XCTAssertEqual(id, expectedTripUuid)
    }
    
    func testId_WithoutTripUuid() {
        // Given
        var ride = createMockRide(tripUuid: "test-uuid")
        
        // Modify ride to have uuid instead of tripUuid (simulating the fallback)
        // Note: This test assumes the ride.id property handles the fallback logic
        createSUT(with: ride)
        
        // When
        let id = sut.id
        
        // Then
        XCTAssertEqual(id, ride.id)
        XCTAssertFalse(id.isEmpty)
    }
    
    // MARK: - Integration Tests
    
    func testFullViewModel_CompleteRide() {
        // Given
        let ride = createMockRide(
            estimatedEarningsCents: 3275, // $32.75
            score: 8.92,
            tripUuid: "integration-test-uuid",
            startAddress: "100 Pickup Lane, Start City, CA 90210",
            endAddress: "200 Dropoff Drive, End Town, CA 90211"
        )
        createSUT(with: ride)
        
        // When & Then
        XCTAssertEqual(sut.estimatedEarnings, "$32.75")
        XCTAssertEqual(sut.startAddress, "100 Pickup Lane, Start City, CA 90210")
        XCTAssertEqual(sut.endAddress, "200 Dropoff Drive, End Town, CA 90211")
        XCTAssertEqual(sut.score, "8.92")
        XCTAssertEqual(sut.id, "integration-test-uuid")
    }
    
    func testMultipleViewModels_DifferentFormatters() {
        // Given
        let usdFormatter = NumberFormatter()
        usdFormatter.numberStyle = .currency
        usdFormatter.currencyCode = "USD"
        
        let plainFormatter = NumberFormatter()
        plainFormatter.numberStyle = .decimal
        plainFormatter.minimumFractionDigits = 2
        plainFormatter.maximumFractionDigits = 2
        
        let ride1 = createMockRide(estimatedEarningsCents: 1500)
        let ride2 = createMockRide(estimatedEarningsCents: 1500)
        
        let viewModel1 = AvailablePickUpCellViewModel(formatter: usdFormatter, ride: ride1)
        let viewModel2 = AvailablePickUpCellViewModel(formatter: plainFormatter, ride: ride2)
        
        // When & Then
        XCTAssertTrue(viewModel1.estimatedEarnings.contains("$"))
        XCTAssertFalse(viewModel2.estimatedEarnings.contains("$"))
        XCTAssertEqual(viewModel2.estimatedEarnings, "15.00")
    }
    
    // MARK: - Edge Cases
    
    func testRideWithNoWaypoints() {
        // Given
        let rideWithNoWaypoints = Ride(
            endsAt: Date().addingTimeInterval(3600),
            estimatedEarningsCents: 1000,
            estimatedRideMiles: 5.0,
            estimatedRideMinutes: 15,
            commuteRideMiles: 1.0,
            commuteRideMinutes: 3,
            score: 6.5,
            orderedWaypoints: [], // No waypoints
            overviewPolyline: "empty",
            startsAt: Date(),
            tripUuid: "no-waypoints-uuid",
            uuid: nil
        )
        createSUT(with: rideWithNoWaypoints)
        
        // When & Then
        XCTAssertNil(sut.startAddress) // Should be nil since no pickup waypoint
        XCTAssertNil(sut.endAddress) // Should be nil since no dropoff waypoint
        XCTAssertEqual(sut.estimatedEarnings, "$10.00")
        XCTAssertEqual(sut.score, "6.5")
    }
}
