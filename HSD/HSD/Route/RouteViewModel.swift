//
//  RouteViewModel.swift
//  HSD
//
//  Created by Justin Lee on 8/27/25.
//

import MapKit
import NetworkService
import SwiftUI

@Observable
class RouteViewModel {
    let overviewPolyline: String
    let wayPoints: [Waypoint]
    let startTime: Date
    let endTime: Date
    
    var position: MapCameraPosition
    var selectedItem: Waypoint?
    
    private let timeFormatter: DateFormatter
    private let timezoneFormatter: DateFormatter
    private let dateFormatter: DateFormatter
    
    init(polyLine: String, waypoints: [Waypoint], startTime: Date, endTime: Date) {
        self.overviewPolyline = polyLine
        self.startTime = startTime
        self.endTime = endTime
        self.wayPoints = waypoints
        
        self.position = Self.createCameraPositionWithRegion(waypoints: waypoints)
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeZone = .current
        timeFormatter.dateFormat = "h:mm a"
        self.timeFormatter = timeFormatter
        
        let timezoneFormatter = DateFormatter()
        timezoneFormatter.timeZone = .current
        timezoneFormatter.dateFormat = "zzz"
        self.timezoneFormatter = timezoneFormatter
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d"
        self.dateFormatter = dateFormatter
    }
    
    var selectedItemDate: String {
        guard let selectedItem = selectedItem else { return startTimeString }
        
        return selectedItem.waypointType == .pickUp ? startTimeString : endTimeString
    }
    
    private var startTimeString: String {
        return generateTimeString(startTime)
    }
    
    private var endTimeString: String {
        return generateTimeString(endTime)
    }
    
    private func generateTimeString(_ waypointDate: Date) -> String {
        let date = dateFormatter.string(from: waypointDate)
        let time = timeFormatter.string(from: waypointDate)
        let timezone = timezoneFormatter.string(from: waypointDate)
        
        return "\(date)\n\(time) (\(timezone))"
    }
    
    //ai gen
    internal static func createCameraPositionWithRegion(waypoints: [Waypoint]) -> MapCameraPosition {
        guard let startWaypoint = waypoints.first(where: { $0.waypointType == .pickUp }),
              let endWaypoint = waypoints.last(where: { $0.waypointType == .dropOff }) else {
            return .automatic
        }
        
        let startCoordinate = CLLocationCoordinate2D(
            latitude: startWaypoint.location.lat,
            longitude: startWaypoint.location.lng
        )
        let endCoordinate = CLLocationCoordinate2D(
            latitude: endWaypoint.location.lat,
            longitude: endWaypoint.location.lng
        )
        
        // Calculate center point
        let centerLat = (startCoordinate.latitude + endCoordinate.latitude) / 2
        let centerLng = (startCoordinate.longitude + endCoordinate.longitude) / 2
        let center = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLng)
        
        // Calculate spans with padding
        let latDelta = abs(startCoordinate.latitude - endCoordinate.latitude) * 1.5 // 50% padding
        let lngDelta = abs(startCoordinate.longitude - endCoordinate.longitude) * 1.5
        
        // Ensure minimum span for very close points
        let minSpan = 0.01
        let span = MKCoordinateSpan(
            latitudeDelta: max(latDelta, minSpan),
            longitudeDelta: max(lngDelta, minSpan)
        )
        
        let region = MKCoordinateRegion(center: center, span: span)
        return .region(region)
    }
    
    //ai gen
    var polyLineCoordinates: [CLLocationCoordinate2D] {
        return overviewPolyline.decodePolyline()
    }
    
    //ai gen
    var mkPolyline: MKPolyline {
        return MKPolyline(coordinates: polyLineCoordinates, count: polyLineCoordinates.count)
    }
}
