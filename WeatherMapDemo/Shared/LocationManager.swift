//
//  LocationManager.swift
//  WeatherMapDemo
//
//  Created by Arbab Nawaz on 9/12/24.
//

import Foundation
import CoreLocation


class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()

    @Published var location: CLLocationCoordinate2D?
    @Published var cityName: String?

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestLocation() {
        manager.requestLocation()
    }
    
    func requestAuthorization() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            print("Location services authorization status undetermined")
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            print("Location services denied")
        default:
            break
        }
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        self.location = location.coordinate
        print(self.location ?? "Location coordinate undetermined")
        // let geocoder = CLGeocoder()
        Task {
            // do {
            //     let placemarks = try await geocoder.reverseGeocodeLocation(location)
            //     guard let placemark = placemarks.first else { return }
            //     DispatchQueue.main.async {
            //         self.cityName = placemark.locality
            //     }
            // } catch {
            //     print("Unable to determine address")
            // }
            await fetchLocationName(location: self.location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("Location amanager failed with eroor: \(error)")
    }
}


extension LocationManager {
    func fetchLocationName(location: CLLocationCoordinate2D?) async {
        guard let location = location else { return }
        Task {
            do {
                let locations = try await NetworkManager.shared.fetchReverseGeoLocation(for: location.latitude, lon: location.longitude)
                DispatchQueue.main.async {
                    self.cityName = locations.first?.name ?? ""
                }
            } catch {
                print("No Locaion Name Found")
            }
        }
    }
}
