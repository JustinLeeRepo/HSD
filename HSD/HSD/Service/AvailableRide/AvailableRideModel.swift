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

struct Ride: Codable, Identifiable {
    let endsAt: Date
    let estimatedEarningsCents: Int
    let estimatedRideMiles: Double
    let estimatedRideMinutes: Int
    let commuteRideMiles: Double
    let commuteRideMinutes: Int
    let score: Double
    let orderedWaypoints: [Waypoint]
    let overviewPolyline: String
    let startsAt: Date
    let tripUuid: String?
    let uuid: String?

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
    
    var id: String {
        tripUuid ?? uuid ?? UUID().uuidString
    }
    
    var startAddress: String? {
        orderedWaypoints.first(where: { $0.waypointType == .pickUp })?.location.address
    }
     
    var endAddress: String? {
        orderedWaypoints.last(where: { $0.waypointType == .dropOff })?.location.address
    }
}

struct Waypoint: Codable {
    let id: Int
    let location: Location
    let waypointType: WaypointType

    enum CodingKeys: String, CodingKey {
        case id
        case location
        case waypointType = "waypoint_type"
    }
}

enum WaypointType: String, Codable {
    case pickUp = "pick_up"
    case dropOff = "drop_off"
}

struct Location: Codable {
    let address: String
    let lat: Double
    let lng: Double
}
