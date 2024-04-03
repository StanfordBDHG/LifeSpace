//
//  MapboxView.swift
//  StrokeCog
//
//  Created by Vishnu Ravi on 4/2/24.
//

import MapboxMaps
import SwiftUI

struct MapManagerViewWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = MapManagerView

    func makeUIViewController(context: Context) -> MapManagerView {
        MapManagerView()
    }

    func updateUIViewController(_ uiViewController: MapManagerView, context: Context) {}
}

public class MapManagerView: UIViewController {
    internal lazy var mapView: MapView = {
        let map = MapView(frame: view.bounds)
        map.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        MapboxMap.initializeMap(mapView: map, reload: true)
        map.location.options.puckType = .puck2D()
        return map
    }()

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(mapView)
    }
}
