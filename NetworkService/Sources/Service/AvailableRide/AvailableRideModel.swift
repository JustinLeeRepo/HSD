//
//  AvailableRideModel.swift
//  HSD
//
//  Created by Justin Lee on 8/26/25.
//

import Foundation

struct RidesResponse: Codable {
    let rides: [Ride]
    let pagination: Pagination
}

struct Pagination: Codable {
    let currentPage: Int
    let pageSize: Int
    let nextPage: Int?
    let totalPages: Int

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case pageSize = "page_size"
        case nextPage = "next_page"
        case totalPages = "total_pages"
    }
}

public struct Ride: Codable, Identifiable {
    public let endsAt: Date
    public let estimatedEarningsCents: Int
    public let estimatedRideMiles: Double
    public let estimatedRideMinutes: Int
    public let commuteRideMiles: Double
    public let commuteRideMinutes: Int
    public let score: Double
    public let orderedWaypoints: [Waypoint]
    public let overviewPolyline: String
    public let startsAt: Date
    public let tripUuid: String?
    public let uuid: String?

    enum CodingKeys: String, CodingKey {
        case endsAt = "ends_at"
        case estimatedEarningsCents = "estimated_earnings_cents"
        case estimatedRideMiles = "estimated_ride_miles"
        case estimatedRideMinutes = "estimated_ride_minutes"
        case commuteRideMiles = "commute_ride_miles"
        case commuteRideMinutes = "commute_ride_minutes"
        case score
        case orderedWaypoints = "ordered_waypoints"
        case overviewPolyline = "overview_polyline"
        case startsAt = "starts_at"
        case tripUuid = "trip_uuid"
        case uuid
    }
    
    public var scoreString: String {
        "\(score)"
    }
    
    public var id: String {
        tripUuid ?? uuid ?? UUID().uuidString
    }
    
    public var startAddress: String? {
        startWaypoint?.location.address
    }
     
    public var endAddress: String? {
        endWaypoint?.location.address
    }
    
    public var startWaypoint: Waypoint? {
        orderedWaypoints.first { $0.waypointType == .pickUp }
    }
    
    public var endWaypoint: Waypoint? {
        orderedWaypoints.last { $0.waypointType == .dropOff }
    }
    
    public var estimatedEarnings: Double {
        let earningsInDollar = Double(estimatedEarningsCents) / 100.00
        return earningsInDollar
    }
    
    public init(
            endsAt: Date,
            estimatedEarningsCents: Int,
            estimatedRideMiles: Double,
            estimatedRideMinutes: Int,
            commuteRideMiles: Double,
            commuteRideMinutes: Int,
            score: Double,
            orderedWaypoints: [Waypoint],
            overviewPolyline: String,
            startsAt: Date,
            tripUuid: String?,
            uuid: String?
        ) {
            self.endsAt = endsAt
            self.estimatedEarningsCents = estimatedEarningsCents
            self.estimatedRideMiles = estimatedRideMiles
            self.estimatedRideMinutes = estimatedRideMinutes
            self.commuteRideMiles = commuteRideMiles
            self.commuteRideMinutes = commuteRideMinutes
            self.score = score
            self.orderedWaypoints = orderedWaypoints
            self.overviewPolyline = overviewPolyline
            self.startsAt = startsAt
            self.tripUuid = tripUuid
            self.uuid = uuid
        }

        // MARK: - Convenience / Mock Init
        public static func mock(
            endsAt: Date = Date(),
            startsAt: Date = Date(),
            estimatedEarningsCents: Int = 0,
            estimatedRideMiles: Double = 0.0,
            estimatedRideMinutes: Int = 0,
            commuteRideMiles: Double = 0.0,
            commuteRideMinutes: Int = 0,
            score: Double = 0.0,
            orderedWaypoints: [Waypoint] = [],
            overviewPolyline: String = "",
            tripUuid: String? = UUID().uuidString,
            uuid: String? = UUID().uuidString
        ) -> Ride {
            Ride(
                endsAt: endsAt,
                estimatedEarningsCents: estimatedEarningsCents,
                estimatedRideMiles: estimatedRideMiles,
                estimatedRideMinutes: estimatedRideMinutes,
                commuteRideMiles: commuteRideMiles,
                commuteRideMinutes: commuteRideMinutes,
                score: score,
                orderedWaypoints: orderedWaypoints,
                overviewPolyline: overviewPolyline,
                startsAt: startsAt,
                tripUuid: tripUuid,
                uuid: uuid
            )
        }
}

public struct Waypoint: Codable, Identifiable, Hashable {
    public static func == (lhs: Waypoint, rhs: Waypoint) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public let id: Int
    public let location: Location
    public let waypointType: WaypointType

    enum CodingKeys: String, CodingKey {
        case id
        case location
        case waypointType = "waypoint_type"
    }

    // MARK: - Init
    public init(
        id: Int,
        location: Location,
        waypointType: WaypointType
    ) {
        self.id = id
        self.location = location
        self.waypointType = waypointType
    }

    // MARK: - Mock
    public static func mock(
        id: Int = Int.random(in: 1...1000),
        location: Location = Location.mock(),
        waypointType: WaypointType = .pickUp
    ) -> Waypoint {
        Waypoint(id: id, location: location, waypointType: waypointType)
    }
}

public enum WaypointType: String, Codable {
    case pickUp = "pick_up"
    case dropOff = "drop_off"
    
    public var displayName: String {
        switch self {
        case .pickUp: return "Pick up"
        case .dropOff: return "Drop off"
        }
    }
}

public struct Location: Codable {
    public let address: String
    public let lat: Double
    public let lng: Double

    public init(address: String, lat: Double, lng: Double) {
        self.address = address
        self.lat = lat
        self.lng = lng
    }

    public static func mock(
        address: String = "123 Main St",
        lat: Double = 37.7749,
        lng: Double = -122.4194
    ) -> Location {
        Location(address: address, lat: lat, lng: lng)
    }
}
