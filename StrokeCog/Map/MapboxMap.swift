//
//  MapboxMap.swift
//  StrokeCog
//
//  Created by Vishnu Ravi on 4/2/24.
//

import Foundation
import MapboxMaps

// swiftlint:disable closure_body_length
class MapboxMap {
    public static func initializeMap (mapView: MapView, reload: Bool) {
        mapView.mapboxMap.onNext(event: .mapLoaded) { _ in
            var locationsPoints = [CLLocationCoordinate2D]()
            locationsPoints = LocationService.shared.allLocations
            do {
                var source = GeoJSONSource(id: "GEOSOURCE")
                source.data = .feature(Feature(geometry: .multiPoint(MultiPoint(locationsPoints))))
                try mapView.mapboxMap.style.addSource(source)

                var circlesLayer = CircleLayer(id: "CIRCLELAYER", source: "GEOSOURCE")
                circlesLayer.circleColor = .constant(StyleColor(.red))
                circlesLayer.circleStrokeColor = .constant(StyleColor(.black))
                circlesLayer.circleStrokeWidth = .constant(2)
                try mapView.mapboxMap.style.addLayer(circlesLayer, layerPosition: .above("country-label"))

                mapView.mapboxMap.setCamera(
                    to: CameraOptions(
                        center: LocationService.shared.allLocations.last,
                        zoom: 14.0
                    )
                )
                if reload {
                    LocationService.shared.onLocationsUpdated = { locations in
                        do {
                            try mapView.mapboxMap.style.updateGeoJSONSource(
                                withId: "GEOSOURCE",
                                geoJSON: .feature(
                                    Feature(
                                        geometry: .lineString(LineString(locations))
                                    )
                                )
                            )
                            mapView.mapboxMap.setCamera(
                                to: CameraOptions(
                                    center: LocationService.shared.allLocations.last,
                                    zoom: 14.0
                                )
                            )
                        } catch let error as NSError {
                            print("[LIFESPACE] Error updating map: \(error.localizedDescription)")
                        }
                    }
                }
            } catch let error as NSError {
                print("[LIFESPACE] Error adding source or layer: \(error.localizedDescription)")
            }
        }
    }
}
