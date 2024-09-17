//
//  WeatherMapViewCoordinator.swift
//  WeatherMapDemo
//
//  Created by Arbab Nawaz on 9/12/24.
//

import Foundation
import SwiftUI

class WeatherMapViewCoordinator: ObservableObject, Identifiable {
    @Published var viewModel = WeatherMapViewModel(networkService: WeatherAPIService())
    
    
    @Published var path: NavigationPath = NavigationPath()


    
    
}
