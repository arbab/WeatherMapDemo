//
//  WeatherMapDemoApp.swift
//  WeatherMapDemo
//
//  Created by Arbab Nawaz on 9/12/24.
//

import SwiftUI

@main
struct WeatherMapDemoApp: App {
    var body: some Scene {
        WindowGroup {
            WeatherMapView(coordinator: WeatherMapViewCoordinator())
        }
    }
}
