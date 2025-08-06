import Foundation
import CoreLocation

// MARK: - Weather Service Protocol
protocol WeatherServiceProtocol {
    func fetchWeather(for coordinate: CLLocationCoordinate2D) async throws -> WeatherResponse
}

// MARK: - Weather Service Implementation
class WeatherService: WeatherServiceProtocol {
    private let session: URLSession
    private let baseURL = "https://api.open-meteo.com/v1/forecast"
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchWeather(for coordinate: CLLocationCoordinate2D) async throws -> WeatherResponse {
        guard let url = buildURL(for: coordinate) else {
            throw WeatherServiceError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw WeatherServiceError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw WeatherServiceError.httpError(httpResponse.statusCode)
            }
            
            let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
            return weatherResponse
            
        } catch let error as DecodingError {
            throw WeatherServiceError.decodingError(error)
        } catch let error as WeatherServiceError {
            throw error
        } catch {
            throw WeatherServiceError.networkError(error)
        }
    }
    
    private func buildURL(for coordinate: CLLocationCoordinate2D) -> URL? {
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "latitude", value: String(coordinate.latitude)),
            URLQueryItem(name: "longitude", value: String(coordinate.longitude)),
            URLQueryItem(name: "current", value: "temperature_2m,weather_code"),
            URLQueryItem(name: "daily", value: "weather_code,temperature_2m_max,temperature_2m_min"),
            URLQueryItem(name: "timezone", value: "auto"),
            URLQueryItem(name: "forecast_days", value: "1")
        ]
        return components?.url
    }
}

// MARK: - Weather Service Errors
enum WeatherServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case networkError(Error)
    case decodingError(DecodingError)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .httpError(let statusCode):
            return "HTTP error with status code: \(statusCode)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        }
    }
}