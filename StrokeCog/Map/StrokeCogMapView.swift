//
//  HomeView.swift
//  LifeSpace
//
//  Created by Vishnu Ravi on 5/18/22.
//  Copyright © 2022 LifeSpace. All rights reserved.
//

import SwiftUI
@_spi(Experimental) import MapboxMaps

// swiftlint:disable closure_body_length file_types_order
struct StrokeCogMapView: View {
    @State private var showingSurveyAlert = false
    @State private var alertMessage = ""
    @State private var showingSurvey = false
    @AppStorage(StorageKeys.trackingPreference) private var trackingOn = true
    @State private var optionsPanelOpen = true
    
    init() {
        MapboxOptions.accessToken = ""
    }
    
    var body: some View {
        ZStack {
            MapManagerViewWrapper()
        }
    }
}

struct ButtonGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.content
            .frame(maxWidth: .infinity)
            .padding()
            .background(RoundedRectangle(cornerRadius: 8).fill(Color("primaryRed")))
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

