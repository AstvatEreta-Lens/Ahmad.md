import XCTest
import CoreLocation
@testable import WeatherApp

@MainActor
class WeatherViewModelTests: XCTestCase {
    var viewModel: WeatherViewModel!
    var mockWeatherService: MockWeatherService!
    var mockLocationManager: MockLocationManager!
    
    override func setUp() {
        super.setUp()
        mockWeatherService = MockWeatherService()
        mockLocationManager = MockLocationManager()
        viewModel = WeatherViewModel(
            weatherService: mockWeatherService,
            locationManager: mockLocationManager
        )
    }
    
    override func tearDown() {
        viewModel = nil
        mockWeatherService = nil
        mockLocationManager = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        XCTAssertNil(viewModel.weatherResponse)
        XCTAssertEqual(viewModel.currentCondition, .unknown)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.currentTemperature, "--°")
        XCTAssertEqual(viewModel.locationText, "Unknown Location")
    }
    
    // MARK: - Load Weather Tests
    
    func testLoadWeatherWithLocationSuccess() async {
        // Given
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        mockLocationManager.currentLocation = coordinate
        mockWeatherService.mockResponse = createMockWeatherResponse()
        
        // When
        viewModel.loadWeather()
        
        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Then
        XCTAssertNotNil(viewModel.weatherResponse)
        XCTAssertEqual(viewModel.currentCondition, .clear)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.currentTemperature, "23°")
    }
    
    func testLoadWeatherWithoutLocation() {
        // Given
        mockLocationManager.currentLocation = nil
        
        // When
        viewModel.loadWeather()
        
        // Then
        XCTAssertTrue(mockLocationManager.requestLocationCalled)
    }
    
    func testLoadWeatherNetworkError() async {
        // Given
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        mockLocationManager.currentLocation = coordinate
        mockWeatherService.shouldThrowError = true
        mockWeatherService.error = WeatherServiceError.networkError(URLError(.notConnectedToInternet))
        
        // When
        viewModel.loadWeather()
        
        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Then
        XCTAssertNil(viewModel.weatherResponse)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.errorMessage!.contains("network"))
    }
    
    // MARK: - Refresh Weather Tests
    
    func testRefreshWeatherSuccess() async {
        // Given
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        mockLocationManager.currentLocation = coordinate
        mockWeatherService.mockResponse = createMockWeatherResponse()
        
        // When
        viewModel.refreshWeather()
        
        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Then
        XCTAssertNotNil(viewModel.weatherResponse)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testRefreshWeatherWithoutLocation() {
        // Given
        mockLocationManager.currentLocation = nil
        
        // When
        viewModel.refreshWeather()
        
        // Then
        XCTAssertEqual(viewModel.errorMessage, "Location not available")
    }
    
    // MARK: - Computed Properties Tests
    
    func testComputedPropertiesWithWeatherData() {
        // Given
        viewModel.weatherResponse = createMockWeatherResponse()
        viewModel.currentCondition = .clear
        
        // Then
        XCTAssertEqual(viewModel.currentTemperature, "23°")
        XCTAssertEqual(viewModel.temperatureUnit, "°C")
        XCTAssertEqual(viewModel.locationText, "America/Los Angeles")
        XCTAssertEqual(viewModel.weatherIcon, "sun.max.fill")
    }
    
    func testHasLocationPermission() {
        // Given - Authorized
        mockLocationManager.authorizationStatus = .authorizedWhenInUse
        
        // Then
        XCTAssertTrue(viewModel.hasLocationPermission)
        
        // Given - Denied
        mockLocationManager.authorizationStatus = .denied
        
        // Then
        XCTAssertFalse(viewModel.hasLocationPermission)
    }
    
    // MARK: - Loading State Tests
    
    func testLoadingStateManagement() async {
        // Given
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        mockLocationManager.currentLocation = coordinate
        mockWeatherService.mockResponse = createMockWeatherResponse()
        mockWeatherService.delay = 0.2 // Add delay to test loading state
        
        // When
        viewModel.loadWeather()
        
        // Then - Initially loading
        XCTAssertTrue(viewModel.isLoading)
        
        // Wait for completion
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        // Then - No longer loading
        XCTAssertFalse(viewModel.isLoading)
    }
    
    // MARK: - Helper Methods
    
    private func createMockWeatherResponse() -> WeatherResponse {
        return WeatherResponse(
            latitude: 37.7749,
            longitude: -122.4194,
            generationtimeMs: 0.123,
            utcOffsetSeconds: -28800,
            timezone: "America/Los_Angeles",
            timezoneAbbreviation: "PST",
            elevation: 56.0,
            currentUnits: CurrentUnits(
                time: "iso8601",
                interval: "seconds",
                temperature2m: "°C",
                weatherCode: "wmo code"
            ),
            current: CurrentWeather(
                time: "2024-01-15T12:00",
                interval: 900,
                temperature2m: 22.5,
                weatherCode: 0
            ),
            dailyUnits: DailyUnits(
                time: "iso8601",
                weatherCode: "wmo code",
                temperature2mMax: "°C",
                temperature2mMin: "°C"
            ),
            daily: DailyWeather(
                time: ["2024-01-15"],
                weatherCode: [0],
                temperature2mMax: [25.0],
                temperature2mMin: [18.0]
            )
        )
    }
}

// MARK: - Mock Weather Service

class MockWeatherService: WeatherServiceProtocol {
    var mockResponse: WeatherResponse?
    var shouldThrowError = false
    var error: Error?
    var delay: TimeInterval = 0
    
    func fetchWeather(for coordinate: CLLocationCoordinate2D) async throws -> WeatherResponse {
        if delay > 0 {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        
        if shouldThrowError {
            throw error ?? WeatherServiceError.networkError(URLError(.unknown))
        }
        
        guard let response = mockResponse else {
            throw WeatherServiceError.invalidResponse
        }
        
        return response
    }
}

// MARK: - Mock Location Manager

class MockLocationManager: LocationManagerProtocol {
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    var requestLocationCalled = false
    
    func requestLocation() {
        requestLocationCalled = true
    }
}