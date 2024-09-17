//
//  WeatherCityViewModel.swift
//  WeatherMapDemo
//
//  Created by Arbab Nawaz on 9/12/24.
//

import Foundation


struct WeatherCityViewModel {
    
    let model: WeatherData
    
    var city: String {
        return model.name
    }
    
    var wind: String {
        return "\(model.wind.speed)"
    }
    
    var primaryWeather: String {
        return model.weather.first?.main ?? ""
    }
    
    var imageURL: URL? {
        
        let icon = model.weather.first?.icon ?? ""
        if icon == "" {
            return nil
        }
        else {
            return URL(string: "\(iconApiBaseURL)\(icon)@2x.png")
        }
    }
}
