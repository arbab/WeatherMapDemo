//
//  NetworkManager.swift
//  WeatherMapDemo
//
//  Created by Arbab Nawaz on 9/12/24.
//

import Foundation
import Combine

protocol NetworkServiceProvider {
    func fetchData<T>(from url: URL) async throws -> T where T : Decodable
}

class NetworkManager {
    public static let shared = NetworkManager()
    
    private var apiURL = baseApiURL
    private var networkService: NetworkServiceProvider?
    
    public func injectService(networkService: NetworkServiceProvider?) {
        self.networkService = networkService
    }

    //    public init() {
    //        self.apiURL = baseApiURL
    //    }
    
    private init() {
    }

    func fetchReverseGeoLocation(for lat: Double, lon: Double) async throws -> [Location]  {
        print("fetchReverseGeoLocation")
        
        guard let networkService = self.networkService else {
            throw (NSError(domain: "No Service Initialiaed", code: -1, userInfo: nil))
        }
        
        let reverseGecodeBaseURL = geocodeApiURL+"/reverse"
        
        let urlStr = reverseGecodeBaseURL+"?lat=\(lat)&lon=\(lon)&limit=2&appid=\(weather_API_KEY)"
        guard let url = URL(string: urlStr) else {
            throw (NSError(domain: "Invalid Reverse Geocoding Url", code: -1, userInfo: nil))
        }
        print("Reverse Geocoding URL: \(url)")
        do {
            let data: [Location] = try await networkService.fetchData(from: url)
            return data
        } catch {
            print(error)
            throw error
        }
    }
    
    
    func fetchWeatherData(for city: String, _ baseURL: String? = nil) async throws -> [WeatherData]  {
        guard city != "" else {
            throw NSError(domain: "City Name Empty", code: -1, userInfo: nil)
        }
        
        guard let networkService = self.networkService else {
            throw (NSError(domain: "No Service Initialiaed", code: -1, userInfo: nil))
        }
        var baseURLString = self.apiURL
        if let baseURL = baseURL{
            baseURLString = baseURL
        }
        
        let urlStr = baseURLString+"?q=\(city)&appid=\(weather_API_KEY)"
        
        print(urlStr)
        guard let url = URL(string: urlStr) else {
            throw (NSError(domain: "Invalid Url", code: -1, userInfo: nil))
        }
        print(url)
        print("fetching user's city weather")
        do {
            let data: WeatherData = try await networkService.fetchData(from: url)
            return [data]
        } catch {
            throw error
        }
    }
}




class MockWeatherAPIService: NetworkServiceProvider {
    var mockData: Data?
    var mockError: Error?
    
    func fetchData<T>(from url: URL) async throws -> T where T : Decodable {
        do {
            if let error = mockError {
                throw (error)
            } else if let data = mockData {
                let decodableData = try JSONDecoder().decode(T.self, from: data)
                return decodableData
            }
        } catch {
            print("Mock Error thrown: \(error)")
            throw error
        }
        throw (NSError(domain: "Mock Error fetching response", code: -1, userInfo: nil))
    }
}

class WeatherAPIService: NetworkServiceProvider {
    let cancellable: AnyCancellable? = nil
    
    func fetchData<T>(from url: URL) async throws -> T where T : Decodable {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodableData = try JSONDecoder().decode(T.self, from: data)
            print("Data received: \(decodableData)")
            return decodableData
        } catch {
            print("Error fetching data: \(error)")
        }
        throw (NSError(domain: "Error fetching response", code: -1, userInfo: nil))
    }
}
