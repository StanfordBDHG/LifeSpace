//
//  MapboxView.swift
//  StrokeCog
//
//  Created by Vishnu Ravi on 4/2/24.
//

import MapboxMaps
import Spezi
import SwiftUI

struct MapManagerViewWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = MapManagerView
    
    @Environment(LocationModule.self) private var locationModule
    
    func makeUIViewController(context: Context) -> MapManagerView {
        MapManagerView(locationModule: locationModule)
    }

    func updateUIViewController(_ uiViewController: MapManagerView, context: Context) {}
}

public class MapManagerView: UIViewController {
    private enum Constants {
        static let geoSourceId = "GEOSOURCE"
        static let circleLayerId = "CIRCLELAYER"
        static let zoomLevel: Double = 14.0
        static let countryLabelLayerId = "country-label"
    }
    
    private var locationModule: LocationModule?
    
    private lazy var mapView: MapView = {
        let map = MapView(frame: view.bounds)
        map.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        map.location.options.puckType = .puck2D()
        map.ornaments.options.scaleBar.visibility = .visible
        return map
    }()
    
    convenience init() {
        self.init(locationModule: nil)
    }
    
    init(locationModule: LocationModule?) {
        self.locationModule = locationModule
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        initializeMap()
        self.view.addSubview(mapView)
    }
    
    /// Initialize map with locations and optional reloading
    private func initializeMap() {
        guard let locationModule else {
            return
        }
        
        self.mapView.mapboxMap.onNext(event: .mapLoaded) { _ in
            let locations = locationModule.allLocations
            do {
                try self.addGeoJSONSource(with: locations)
                try self.addCircleLayer(sourceId: Constants.geoSourceId)
                self.centerCamera(at: locations.last, zoomLevel: Constants.zoomLevel)
                self.setupDynamicLocationUpdates()
            } catch {
                print("[MapboxMap] Error: \(error.localizedDescription)")
            }
        }
    }
    
    /// Add GeoJSON source to the map
    private func addGeoJSONSource(with locations: [CLLocationCoordinate2D]) throws {
        var source = GeoJSONSource(id: Constants.geoSourceId)
        source.data = .feature(Feature(geometry: .multiPoint(MultiPoint(locations))))
        try mapView.mapboxMap.addSource(source)
    }
    
    /// Add circle layer to the map
    private func addCircleLayer(sourceId: String) throws {
        var circlesLayer = CircleLayer(id: Constants.circleLayerId, source: sourceId)
        circlesLayer.circleColor = .constant(StyleColor(.red))
        circlesLayer.circleStrokeColor = .constant(StyleColor(.black))
        circlesLayer.circleStrokeWidth = .constant(2)
        try mapView.mapboxMap.addLayer(circlesLayer)
    }
    
    /// Center the map's camera
    private func centerCamera(at location: CLLocationCoordinate2D?, zoomLevel: Double) {
        guard let center = location else {
            return
        }
        
        mapView.mapboxMap.setCamera(to: CameraOptions(center: center, zoom: zoomLevel))
    }
    
    /// Set up dynamic updates for locations
    private func setupDynamicLocationUpdates() {
        guard let locationModule else {
            return
        }
        
        locationModule.onLocationsUpdated = { locations in
            self.mapView.mapboxMap.updateGeoJSONSource(
                withId: Constants.geoSourceId,
                geoJSON: .feature(Feature(geometry: .lineString(LineString(locations))))
            )
            self.centerCamera(at: locations.last, zoomLevel: Constants.zoomLevel)
        }
    }
}
