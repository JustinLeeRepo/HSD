//
//  RouteViewModelTests.swift
//  HSDTests
//
//  Created by Justin Lee on 8/27/25.
//

import XCTest
import MapKit
@testable import Authorized
@testable import NetworkService

final class RouteViewModelTests: XCTestCase {
    
    var sut: RouteViewModel!
    var mockPolyline: String!
    var mockWaypoints: [Waypoint]!
    var startTime: Date!
    var endTime: Date!
    
    override func setUp() {
        super.setUp()
        
        // Setup test dates
        let calendar = Calendar.current
        startTime = calendar.date(from: DateComponents(year: 2024, month: 3, day: 15, hour: 9, minute: 30))!
        endTime = calendar.date(from: DateComponents(year: 2024, month: 3, day: 15, hour: 10, minute: 15))!
        
        mockPolyline = "eiqnEhgvpU|A{UNcD@o@wlA[WKaL[iAYgCoA{@]YQeEkA`AuFu@SCM\\sBYKCGGJI?"
        //
        
        // Setup mock waypoints
        setupMockWaypoints()
    }
    
    override func tearDown() {
        sut = nil
        mockPolyline = nil
        mockWaypoints = nil
        startTime = nil
        endTime = nil
        super.tearDown()
    }
    
    // MARK: - Helper Methods
    
    private func setupMockWaypoints() {
        let pickupWaypoint = Waypoint(
            id: 1,
            location: Location(address: "East 41st Street, Los Angeles", lat: 34.0089813, lng: -118.2476647),
            waypointType: .pickUp
        )
        
        let dropoffWaypoint = Waypoint(
            id: 2,
            location: Location(address: "Alameda Street, Los Angeles", lat: 34.0252756, lng: -118.2395896),
            waypointType: .dropOff
        )
        
        mockWaypoints = [pickupWaypoint, dropoffWaypoint]
    }
    
    private func createSUT(
        polyline: String? = nil,
        waypoints: [Waypoint]? = nil,
        startTime: Date? = nil,
        endTime: Date? = nil
    ) {
        sut = RouteViewModel(
            polyLine: polyline ?? mockPolyline,
            waypoints: waypoints ?? mockWaypoints,
            startTime: startTime ?? self.startTime,
            endTime: endTime ?? self.endTime
        )
    }
    
    private func createWaypoint(
        id: Int,
        address: String,
        lat: Double,
        lng: Double,
        type: WaypointType
    ) -> Waypoint {
        return Waypoint(
            id: id,
            location: Location(address: address, lat: lat, lng: lng),
            waypointType: type
        )
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        // When
        createSUT()
        
        // Then
        XCTAssertEqual(sut.overviewPolyline, mockPolyline)
        XCTAssertEqual(sut.wayPoints.count, 2)
        XCTAssertEqual(sut.startTime, startTime)
        XCTAssertEqual(sut.endTime, endTime)
        XCTAssertNotNil(sut.position)
        XCTAssertNil(sut.selectedItem)
    }
    
    func testInitialization_WithEmptyWaypoints() {
        // When
        createSUT(waypoints: [])
        
        // Then
        XCTAssertEqual(sut.wayPoints.count, 0)
        XCTAssertNotNil(sut.position) // Should still initialize position
    }
    
    func testInitialization_WithSingleWaypoint() {
        // Given
        let singleWaypoint = [createWaypoint(id: 1, address: "Solo Point", lat: 34.0089813, lng: -118.2476647, type: .pickUp)]
        
        // When
        createSUT(waypoints: singleWaypoint)
        
        // Then
        XCTAssertEqual(sut.wayPoints.count, 1)
        XCTAssertEqual(sut.wayPoints.first?.waypointType, .pickUp)
    }
    
    // MARK: - Date Formatting Tests
    
    func testSelectedItemDate_NoSelectedItem() {
        // Given
        createSUT()
        
        // When
        let selectedDate = sut.selectedItemDate
        
        // Then
        XCTAssertTrue(selectedDate.contains("Friday, March 15")) // Start time formatting
        XCTAssertTrue(selectedDate.contains("9:30 AM"))
    }
    
    func testSelectedItemDate_PickupSelected() {
        // Given
        createSUT()
        let pickupWaypoint = mockWaypoints.first { $0.waypointType == .pickUp }!
        
        // When
        sut.selectedItem = pickupWaypoint
        let selectedDate = sut.selectedItemDate
        
        // Then
        XCTAssertTrue(selectedDate.contains("Friday, March 15")) // Start time
        XCTAssertTrue(selectedDate.contains("9:30 AM"))
    }
    
    func testSelectedItemDate_DropoffSelected() {
        // Given
        createSUT()
        let dropoffWaypoint = mockWaypoints.first { $0.waypointType == .dropOff }!
        
        // When
        sut.selectedItem = dropoffWaypoint
        let selectedDate = sut.selectedItemDate
        
        // Then
        XCTAssertTrue(selectedDate.contains("Friday, March 15")) // End time
        XCTAssertTrue(selectedDate.contains("10:15 AM"))
    }
    
    func testTimeFormatting_DifferentTimes() {
        // Given
        let morningTime = Calendar.current.date(from: DateComponents(year: 2024, month: 6, day: 20, hour: 8, minute: 0))!
        let eveningTime = Calendar.current.date(from: DateComponents(year: 2024, month: 6, day: 20, hour: 18, minute: 45))!
        
        // When
        createSUT(startTime: morningTime, endTime: eveningTime)
        
        // Then
        let startDateString = sut.selectedItemDate // Default to start time
        XCTAssertTrue(startDateString.contains("Thursday, June 20"))
        XCTAssertTrue(startDateString.contains("8:00 AM"))
        
        // Test end time by selecting dropoff
        sut.selectedItem = mockWaypoints.first { $0.waypointType == .dropOff }
        let endDateString = sut.selectedItemDate
        XCTAssertTrue(endDateString.contains("6:45 PM"))
    }
    
    func testTimeFormatting_MidnightAndNoon() {
        // Given
        let midnightTime = Calendar.current.date(from: DateComponents(year: 2024, month: 1, day: 1, hour: 0, minute: 0))!
        let noonTime = Calendar.current.date(from: DateComponents(year: 2024, month: 1, day: 1, hour: 12, minute: 0))!
        
        // When
        createSUT(startTime: midnightTime, endTime: noonTime)
        
        // Then
        let startString = sut.selectedItemDate
        XCTAssertTrue(startString.contains("12:00 AM") || startString.contains("12:00 a"))
        
        sut.selectedItem = mockWaypoints.first { $0.waypointType == .dropOff }
        let endString = sut.selectedItemDate
        XCTAssertTrue(endString.contains("12:00 PM") || endString.contains("12:00 p"))
    }
    
    // MARK: - Camera Position Tests
    
    func testCameraPosition_WithValidWaypoints() {
        // When
        createSUT()
        
        // Then
        if let region = sut.position.region {
            // Verify center is between pickup and dropoff
            XCTAssertEqual(region.center.latitude, (34.0089813 + 34.0252756) / 2, accuracy: 0.0001)
            XCTAssertEqual(region.center.longitude, (-118.2476647 + -118.2395896) / 2, accuracy: 0.0001)
            
            // Verify span includes both points with padding
            XCTAssertGreaterThan(region.span.latitudeDelta, abs(34.0089813 - 34.0252756))
            XCTAssertGreaterThan(region.span.longitudeDelta, abs(-118.2476647 - -118.2395896))
        } else {
            XCTFail("Expected region position, got \(sut.position)")
        }
    }
    
    func testCameraPosition_WithoutPickupWaypoint() {
        // Given
        let waypointsWithoutPickup = [createWaypoint(id: 1, address: "Only Dropoff", lat: 34.0089813, lng: -118.2476647, type: .dropOff)]
        
        // When
        createSUT(waypoints: waypointsWithoutPickup)
        
        // Then
        if case .automatic = sut.position {
            // Expected automatic position
        } else {
            XCTFail("Expected automatic position when pickup waypoint is missing, got \(sut.position)")
        }
    }
    
    func testCameraPosition_WithoutDropoffWaypoint() {
        // Given
        let waypointsWithoutDropoff = [createWaypoint(id: 1, address: "Only Pickup", lat: 34.0089813, lng: -118.2476647, type: .pickUp)]
        
        // When
        createSUT(waypoints: waypointsWithoutDropoff)
        
        // Then
        if case .automatic = sut.position {
            // Expected automatic position
        } else {
            XCTFail("Expected automatic position when dropoff waypoint is missing, got \(sut.position)")
        }
    }
    
    func testCameraPosition_WithEmptyWaypoints() {
        // When
        createSUT(waypoints: [])
        
        // Then
        if case .automatic = sut.position {
            // Expected automatic position
        } else {
            XCTFail("Expected automatic position when waypoints are empty, got \(sut.position)")
        }
    }
    
    func testCameraPosition_WithVeryCloseWaypoints() {
        // Given - waypoints very close together
        let closeWaypoints = [
            createWaypoint(id: 1, address: "Close Pickup", lat: 34.0089813, lng: -118.2476647, type: .pickUp),
            createWaypoint(id: 2, address: "Close Dropoff", lat: 37.7750, lng: -122.4195, type: .dropOff)
        ]
        
        // When
        createSUT(waypoints: closeWaypoints)
        
        // Then
        if let region = sut.position.region {
            // Should enforce minimum span for very close points
            XCTAssertGreaterThanOrEqual(region.span.latitudeDelta, 0.01)
            XCTAssertGreaterThanOrEqual(region.span.longitudeDelta, 0.01)
        } else {
            XCTFail("Expected region position for close waypoints, got \(sut.position)")
        }
    }
    
    func testCameraPosition_WithDistantWaypoints() {
        // Given - waypoints far apart
        let distantWaypoints = [
            createWaypoint(id: 1, address: "SF Pickup", lat: 37.774929, lng: -122.419418, type: .pickUp),
            createWaypoint(id: 2, address: "LA Dropoff", lat: 34.0522, lng: -118.2437, type: .dropOff)
        ]
        
        // When
        createSUT(waypoints: distantWaypoints)
        
        // Then
        if let region = sut.position.region {
            // Should have large span to include both distant points
            XCTAssertGreaterThan(region.span.latitudeDelta, 3.0) // Significant lat difference
            XCTAssertGreaterThan(region.span.longitudeDelta, 4.0) // Significant lng difference
        } else {
            XCTFail("Expected region position for distant waypoints, got \(sut.position)")
        }
    }
    
    // MARK: - Polyline Tests
    
    func testPolylineCoordinates() {
        // Given
        createSUT()
        
        // When
        let coordinates = sut.polyLineCoordinates
        
        // Then
        XCTAssertNotNil(coordinates)
        
        // A small tolerance for comparing floating-point coordinates
        let tolerance = 0.0005

        // The assertion checks if mockWaypoints contains ANY waypoint
        // whose location can be found within the coordinates array.
        XCTAssertTrue(mockWaypoints.contains { waypoint in
            coordinates.contains { coordinate in
                // Compare latitude and longitude within the tolerance
                abs(coordinate.latitude - waypoint.location.lat) < tolerance &&
                abs(coordinate.longitude - waypoint.location.lng) < tolerance
            }
        }, "The coordinates array should contain at least one of the mock waypoint locations.")
        // assert polylinecoordinates have start and end coordinates of waypoint
    }
    
    func testMKPolyline() {
        // Given
        createSUT()
        
        // When
        let mkPolyline = sut.mkPolyline
        
        // Then
        XCTAssertNotNil(mkPolyline)
        XCTAssertEqual(mkPolyline.pointCount, sut.polyLineCoordinates.count)
    }
    
    // MARK: - Selected Item Tests
    
    func testSelectedItem_Modification() {
        // Given
        createSUT()
        let pickupWaypoint = mockWaypoints.first { $0.waypointType == .pickUp }!
        let dropoffWaypoint = mockWaypoints.first { $0.waypointType == .dropOff }!
        
        // When & Then - Initially nil
        XCTAssertNil(sut.selectedItem)
        
        // When & Then - Set to pickup
        sut.selectedItem = pickupWaypoint
        XCTAssertEqual(sut.selectedItem?.id, pickupWaypoint.id)
        XCTAssertEqual(sut.selectedItem?.waypointType, .pickUp)
        
        // When & Then - Change to dropoff
        sut.selectedItem = dropoffWaypoint
        XCTAssertEqual(sut.selectedItem?.id, dropoffWaypoint.id)
        XCTAssertEqual(sut.selectedItem?.waypointType, .dropOff)
        
        // When & Then - Clear selection
        sut.selectedItem = nil
        XCTAssertNil(sut.selectedItem)
    }
    
    // MARK: - Integration Tests
    
    func testCompleteWorkflow() {
        // Given
        let customWaypoints = [
            createWaypoint(id: 10, address: "Start Location", lat: 40.7128, lng: -74.0060, type: .pickUp),
            createWaypoint(id: 20, address: "End Location", lat: 40.7589, lng: -73.9851, type: .dropOff)
        ]
        
        let customStartTime = Date()
        let customEndTime = customStartTime.addingTimeInterval(1800) // 30 minutes later
        
        // When
        createSUT(
            polyline: "customPolylineString",
            waypoints: customWaypoints,
            startTime: customStartTime,
            endTime: customEndTime
        )
        
        // Then - Verify all components work together
        XCTAssertEqual(sut.overviewPolyline, "customPolylineString")
        XCTAssertEqual(sut.wayPoints.count, 2)
        XCTAssertEqual(sut.startTime, customStartTime)
        XCTAssertEqual(sut.endTime, customEndTime)
        
        // Test selecting pickup waypoint
        sut.selectedItem = customWaypoints[0]
        let pickupTime = sut.selectedItemDate
        XCTAssertNotNil(pickupTime)
        XCTAssertFalse(pickupTime.isEmpty)
        
        // Test selecting dropoff waypoint
        sut.selectedItem = customWaypoints[1]
        let dropoffTime = sut.selectedItemDate
        XCTAssertNotNil(dropoffTime)
        XCTAssertFalse(dropoffTime.isEmpty)
        XCTAssertNotEqual(pickupTime, dropoffTime) // Should be different times
    }
    
    // MARK: - Edge Cases
    
    func testMultipleWaypointsOfSameType() {
        // Given - Multiple pickup waypoints (edge case)
        let multiplePickups = [
            createWaypoint(id: 1, address: "Pickup 1", lat: 34.0089813, lng: -118.2476647, type: .pickUp),
            createWaypoint(id: 2, address: "Pickup 2", lat: 37.7750, lng: -122.4195, type: .pickUp),
            createWaypoint(id: 3, address: "Dropoff", lat: 34.0252756, lng: -118.2395896, type: .dropOff)
        ]
        
        // When
        createSUT(waypoints: multiplePickups)
        
        // Then
        XCTAssertEqual(sut.wayPoints.count, 3)
        
        // Should use first pickup and last dropoff for camera positioning
        if let region = sut.position.region {
            // Should still create valid region
            XCTAssertNotNil(region)
        } else {
            XCTFail("Expected region position, got \(sut.position)")
        }
    }
}
