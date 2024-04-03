//
//  HomeView.swift
//  StrokeCog
//
//  Created by Vishnu Ravi on 4/2/24.
//  Copyright © 2024 StrokeCog. All rights reserved.
//

@_spi(Experimental) import MapboxMaps
import SwiftUI

struct StrokeCogMapView: View {
    @AppStorage(StorageKeys.trackingPreference) private var trackingOn = true
    
    @State private var showingSurveyAlert = false
    @State private var alertMessage = ""
    @State private var showingSurvey = false
    @State private var optionsPanelOpen = true
    
    var body: some View {
        ZStack {
            MapManagerViewWrapper()
        }
    }
    
    init() {
        MapboxOptions.accessToken = ""
    }
}

struct StrokeCogMapView_Previews: PreviewProvider {
    static var previews: some View {
        StrokeCogMapView()
    }
}
