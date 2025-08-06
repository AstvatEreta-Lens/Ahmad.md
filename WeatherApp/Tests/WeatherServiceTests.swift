import XCTest
import CoreLocation
@testable import WeatherApp

class WeatherServiceTests: XCTestCase {
    var weatherService: WeatherService!
    var mockURLSession: MockURLSession!
    
    override func setUp() {
        super.setUp()
        mockURLSession = MockURLSession()
        weatherService = WeatherService(session: mockURLSession)
    }
    
    override func tearDown() {
        weatherService = nil
        mockURLSession = nil
        super.tearDown()
    }
    
    // MARK: - Success Tests
    
    func testFetchWeatherSuccess() async throws {
        // Given
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let mockResponse = createMockWeatherResponse()
        let mockData = try JSONEncoder().encode(mockResponse)
        
        mockURLSession.data = mockData
        mockURLSession.response = HTTPURLResponse(
            url: URL(string: "https://api.open-meteo.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When
        let result = try await weatherService.fetchWeather(for: coordinate)
        
        // Then
        XCTAssertEqual(result.latitude, mockResponse.latitude)
        XCTAssertEqual(result.longitude, mockResponse.longitude)
        XCTAssertEqual(result.current.temperature2m, mockResponse.current.temperature2m)
        XCTAssertEqual(result.current.weatherCode, mockResponse.current.weatherCode)
    }
    
    // MARK: - Error Tests
    
    func testFetchWeatherNetworkError() async {
        // Given
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        mockURLSession.error = URLError(.notConnectedToInternet)
        
        // When & Then
        do {
            _ = try await weatherService.fetchWeather(for: coordinate)
            XCTFail("Expected network error")
        } catch let error as WeatherServiceError {
            if case .networkError = error {
                // Success - expected network error
            } else {
                XCTFail("Expected network error, got \(error)")
            }
        } catch {
            XCTFail("Expected WeatherServiceError, got \(error)")
        }
    }
    
    func testFetchWeatherHTTPError() async {
        // Given
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        mockURLSession.data = Data()
        mockURLSession.response = HTTPURLResponse(
            url: URL(string: "https://api.open-meteo.com")!,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When & Then
        do {
            _ = try await weatherService.fetchWeather(for: coordinate)
            XCTFail("Expected HTTP error")
        } catch let error as WeatherServiceError {
            if case .httpError(let statusCode) = error {
                XCTAssertEqual(statusCode, 404)
            } else {
                XCTFail("Expected HTTP error, got \(error)")
            }
        } catch {
            XCTFail("Expected WeatherServiceError, got \(error)")
        }
    }
    
    func testFetchWeatherDecodingError() async {
        // Given
        let coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let invalidData = "Invalid JSON".data(using: .utf8)!
        
        mockURLSession.data = invalidData
        mockURLSession.response = HTTPURLResponse(
            url: URL(string: "https://api.open-meteo.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When & Then
        do {
            _ = try await weatherService.fetchWeather(for: coordinate)
            XCTFail("Expected decoding error")
        } catch let error as WeatherServiceError {
            if case .decodingError = error {
                // Success - expected decoding error
            } else {
                XCTFail("Expected decoding error, got \(error)")
            }
        } catch {
            XCTFail("Expected WeatherServiceError, got \(error)")
        }
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

// MARK: - Mock URL Session

class MockURLSession: URLSession {
    var data: Data?
    var response: URLResponse?
    var error: Error?
    
    override func data(from url: URL) async throws -> (Data, URLResponse) {
        if let error = error {
            throw error
        }
        
        guard let data = data, let response = response else {
            throw URLError(.unknown)
        }
        
        return (data, response)
    }
}