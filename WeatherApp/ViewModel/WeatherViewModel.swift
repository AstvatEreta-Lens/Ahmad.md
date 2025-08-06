import Foundation
import CoreLocation
import SwiftUI

// MARK: - Weather View Model
@MainActor
class WeatherViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var weatherResponse: WeatherResponse?
    @Published var currentCondition: WeatherCondition = .unknown
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    private let weatherService: WeatherServiceProtocol
    private let locationManager: LocationManagerProtocol
    
    // MARK: - Computed Properties
    var currentTemperature: String {
        guard let weather = weatherResponse else { return "--°" }
        return String(format: "%.0f°", weather.current.temperature2m)
    }
    
    var temperatureUnit: String {
        return weatherResponse?.currentUnits.temperature2m ?? "°C"
    }
    
    var locationText: String {
        guard let weather = weatherResponse else { return "Unknown Location" }
        return weather.timezone.replacingOccurrences(of: "_", with: " ")
    }
    
    var backgroundGradient: LinearGradient {
        return currentCondition.backgroundGradient
    }
    
    var weatherIcon: String {
        return currentCondition.systemImageName
    }
    
    var hasLocationPermission: Bool {
        return locationManager.authorizationStatus == .authorizedWhenInUse || 
               locationManager.authorizationStatus == .authorizedAlways
    }
    
    // MARK: - Initialization
    init(weatherService: WeatherServiceProtocol = WeatherService(), 
         locationManager: LocationManagerProtocol = LocationManager()) {
        self.weatherService = weatherService
        self.locationManager = locationManager
        
        // Observe location changes
        setupLocationObserver()
    }
    
    // MARK: - Public Methods
    func loadWeather() {
        guard !isLoading else { return }
        
        // Clear previous error
        errorMessage = nil
        
        // Check if we have location
        if let location = locationManager.currentLocation {
            fetchWeather(for: location)
        } else {
            // Request location if not available
            locationManager.requestLocation()
        }
    }
    
    func refreshWeather() {
        guard let location = locationManager.currentLocation else {
            errorMessage = "Location not available"
            return
        }
        
        fetchWeather(for: location)
    }
    
    // MARK: - Private Methods
    private func setupLocationObserver() {
        // This would typically use Combine or similar for real-time updates
        // For simplicity, we'll check location in loadWeather()
    }
    
    private func fetchWeather(for coordinate: CLLocationCoordinate2D) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let response = try await weatherService.fetchWeather(for: coordinate)
                
                await MainActor.run {
                    self.weatherResponse = response
                    self.currentCondition = WeatherCondition.from(weatherCode: response.current.weatherCode)
                    self.isLoading = false
                }
                
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - Preview Helper
extension WeatherViewModel {
    static func preview() -> WeatherViewModel {
        let viewModel = WeatherViewModel()
        
        // Mock data for preview
        viewModel.weatherResponse = WeatherResponse(
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
        
        viewModel.currentCondition = .clear
        
        return viewModel
    }
}