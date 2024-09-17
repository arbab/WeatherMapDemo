//
//  WeatherMapViewModelTest.swift
//  WeatherMapDemoTests
//
//  Created by Arbab Nawaz on 9/13/24.
//

import XCTest
@testable import WeatherMapDemo

final class WeatherMapViewModelTest: XCTestCase {

    private var cityName = "London"
    var results: [WeatherData] = []

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLoadData() {
        let viewModel = WeatherMapViewModel(networkService: WeatherAPIService())
        viewModel.searchText = cityName
        Task {  await viewModel.loadData() }
        XCTAssertNotNil(viewModel.results, "City Name shouldn't be nil")
    }
    
    func testLoadEmptyCityError() {
        let viewModel = WeatherMapViewModel(networkService: WeatherAPIService())
        viewModel.searchText = cityName
        viewModel.networkManager.injectService(networkService: nil)
        Task {  await viewModel.loadData() }
        XCTAssertFalse(viewModel.isLoading, "City should not be loading anything")
    }

    func testLoadDataException() {
        let viewModel = WeatherMapViewModel(networkService: WeatherAPIService())
        viewModel.searchText = ""
        Task {  await viewModel.loadData() }
        XCTAssertFalse(viewModel.isLoading, "City should not be loading anything")
    }
    
    func testViewModelLoadsRemoteDataSuccessfully() async throws  {
        let viewModel = WeatherMapViewModel(networkService: WeatherAPIService())
        viewModel.searchText = cityName
        
        let task = Task {  try await viewModel.networkManager.fetchWeatherData(for: viewModel.searchText) }
        
        // Yield the above task to ensure it's constructed and finished.
        await Task.yield()
        
        let weatherData = try await task.value
        print(weatherData)
        
        let name = weatherData.first?.name
        
        XCTAssertNotNil(name, "City Name shouldn't be nil")
        XCTAssert(name == cityName, "City Name should be \(weatherData)")
    }
    
    
    
    func testViewModelLoadsMockDataSuccessfully() async throws {
        let mockData: Data? = Mock().load(type: .weather)
        print(mockData!)
        let mockWeatherAPIService: MockWeatherAPIService = MockWeatherAPIService()
        mockWeatherAPIService.mockData = mockData
        let mockNetworkManager: NetworkManager = NetworkManager.shared
        mockNetworkManager.injectService(networkService: mockWeatherAPIService)
        
        let viewModel = WeatherMapViewModel(networkService: mockWeatherAPIService)
        viewModel.searchText = "Tamarac"
        
        let task = Task {  try await viewModel.networkManager.fetchWeatherData(for: viewModel.searchText) }
        
        // Yield the above task to ensure it's constructed and finished.
        await Task.yield()
        
        let weatherData = try await task.value
        print(weatherData)
        
        let name = weatherData.first?.name
        
        XCTAssertNotNil(name, "City Name shouldn't be nil")
        XCTAssert(name == viewModel.searchText, "City Name should be \(viewModel.searchText)")
    }
    
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
