//
//  String+Extensions.swift
//  HSD
//
//  Created by Justin Lee on 8/27/25.
//

import CoreLocation
import MapKit

//ai gen
extension String {
    
    /// Decodes a polyline string into an array of `CLLocationCoordinate2D` objects.
    ///
    /// - Returns: An array of coordinates representing the polyline's path.
    func decodePolyline() -> [CLLocationCoordinate2D] {
        // Convert the string to a byte array
        let bytes = [UInt8](self.utf8)
        guard !bytes.isEmpty else { return [] }
        
        var index = 0
        var coordinates: [CLLocationCoordinate2D] = []
        
        var previousLatitude: Int32 = 0
        var previousLongitude: Int32 = 0
        
        while index < bytes.count {
            // Decode the latitude difference
            let latitudeChange = decodeComponent(from: bytes, index: &index)
            previousLatitude += latitudeChange
            
            // If the end of the string is reached after decoding latitude, break
            guard index < bytes.count else { break }
            
            // Decode the longitude difference
            let longitudeChange = decodeComponent(from: bytes, index: &index)
            previousLongitude += longitudeChange
            
            // Create the coordinate and add it to the array
            let coordinate = CLLocationCoordinate2D(
                latitude: Double(previousLatitude) / 1e5,
                longitude: Double(previousLongitude) / 1e5
            )
            coordinates.append(coordinate)
        }
        
        return coordinates
    }
    
    /// A helper function to decode a single latitude or longitude component from the byte array.
    private func decodeComponent(from bytes: [UInt8], index: inout Int) -> Int32 {
        var result: Int32 = 0
        var shift: Int32 = 0
        var byte: Int32
        
        repeat {
            guard index < bytes.count else { break }
            byte = Int32(bytes[index]) - 63
            index += 1
            result |= (byte & 0x1f) << shift
            shift += 5
        } while byte >= 0x20
        
        // Apply the sign inversion if the LSB is 1
        return ((result & 1) != 0 ? ~(result >> 1) : (result >> 1))
    }
}
