//
//  Mock.swift
//  WeatherMapDemo
//
//  Created by Arbab Nawaz on 9/12/24.
//

import Foundation

enum MockType: String {
    case none
    case error
    case weather
}

class Mock {
    
    let fileManager = FileManager()
    
    static let shared = Mock()
    
    func load(type: MockType) -> Data? {
        
        if type == .none {
            return nil
        }
        
        var data: Data? = nil
        if let path = Bundle.main.path(forResource: type.rawValue, ofType: "json"),
            fileManager.fileExists(atPath: path) {
            data = fileManager.contents(atPath: path)
        }
        return data
    }
    
    func load(type: MockType) -> [WeatherData]? {
        
        if type == .none {
            return nil
        }
        
        var data: Data? = nil
        if let path = Bundle.main.path(forResource: type.rawValue, ofType: "json"),
            fileManager.fileExists(atPath: path) {
            data = fileManager.contents(atPath: path)
            guard let data = data else {return []}
            do {
                let weather = try JSONDecoder().decode([WeatherData].self, from: data)
                return weather
            } catch {
                print ("erro")
            }

        }
        return []
        

        
    }
    
    
}
