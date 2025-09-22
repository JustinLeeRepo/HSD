//
//  RouteView.swift
//  HSD
//
//  Created by Justin Lee on 8/27/25.
//

import SwiftUI
import MapKit

struct RouteView: View {
    @Bindable var viewModel: RouteViewModel
    
    var body: some View {
        Map(position: $viewModel.position, selection: $viewModel.selectedItem) {
            ForEach(viewModel.wayPoints, id: \.self) { waypoint in
                let lat = waypoint.location.lat
                let long = waypoint.location.lng
                let coord = CLLocationCoordinate2D(latitude: lat, longitude: long)
                let type = waypoint.waypointType
                
                Marker(type.displayName, coordinate: coord)
                    .tint(type == .pickUp ? .green : .red)
            }
            
            MapPolyline(coordinates: viewModel.polyLineCoordinates)
                .stroke(.blue, lineWidth: 5)
                .mapOverlayLevel(level: .aboveLabels)
        }
        .mapStyle(.standard(elevation: .realistic))
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
            MapPitchToggle()
        }
        .sheet(item: $viewModel.selectedItem) { selectedItem in
            VStack(spacing: 8) {
                HStack {
                    Text("📍")
                    Text(selectedItem.location.address)
                        .multilineTextAlignment(.leading)
                }
                
                HStack {
                    Text("⏰")
                    Text(viewModel.selectedItemDate)
                        .multilineTextAlignment(.leading)
                }
            }
            .presentationDragIndicator(.visible)
            .presentationDetents([.fraction(0.25)])
            .presentationBackground(.thickMaterial)
        }
    }
}

//#Preview {
//    RouteView()
//}
