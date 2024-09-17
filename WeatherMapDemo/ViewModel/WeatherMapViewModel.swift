//
//  WeatherMapViewModel.swift
//  WeatherMapDemo
//
//  Created by Arbab Nawaz on 9/12/24.
//

import Foundation

class WeatherMapViewModel: ObservableObject, Identifiable {
    
    public var id = UUID()
    let networkManager =  NetworkManager.shared
    
    @Published var results: [WeatherData] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var error: Error?

    private func setupNetworkConfiguration(networkService: NetworkServiceProvider) {
        self.networkManager.injectService(networkService: networkService)
    }
    
    init(networkService: NetworkServiceProvider) {
        self.setupNetworkConfiguration(networkService: networkService)
    }
    
    func loadData() async {
        if searchText.isEmpty {
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
            }
        } else {
            Task {
                do {
                    DispatchQueue.main.async { [weak self] in
                        self?.isLoading = true
                    }
                    let data = try await networkManager.fetchWeatherData(for: searchText)
                    DispatchQueue.main.async { [weak self] in
                        self?.results = data
                        self?.isLoading = false
                        print(self?.results ?? [])
                    }
                } catch{
                    print(error)
                    DispatchQueue.main.async { [weak self] in
                        self?.isLoading = false
                        self?.results = []
                        self?.error = error
                    }
                }
            }
        }
    }
}
