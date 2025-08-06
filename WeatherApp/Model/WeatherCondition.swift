import Foundation
import SwiftUI

// MARK: - Weather Condition Enum
enum WeatherCondition: String, CaseIterable {
    case clear = "Clear"
    case partlyCloudy = "Partly Cloudy"
    case cloudy = "Cloudy"
    case overcast = "Overcast"
    case fog = "Fog"
    case drizzle = "Drizzle"
    case rain = "Rain"
    case heavyRain = "Heavy Rain"
    case snow = "Snow"
    case thunderstorm = "Thunderstorm"
    case unknown = "Unknown"
    
    // Map Open-Meteo weather codes to conditions
    static func from(weatherCode: Int) -> WeatherCondition {
        switch weatherCode {
        case 0:
            return .clear
        case 1, 2:
            return .partlyCloudy
        case 3:
            return .cloudy
        case 45, 48:
            return .fog
        case 51, 53, 55:
            return .drizzle
        case 56, 57:
            return .drizzle // Freezing drizzle
        case 61, 63:
            return .rain
        case 65:
            return .heavyRain
        case 66, 67:
            return .rain // Freezing rain
        case 71, 73, 75:
            return .snow
        case 77:
            return .snow // Snow grains
        case 80, 81, 82:
            return .rain // Rain showers
        case 85, 86:
            return .snow // Snow showers
        case 95:
            return .thunderstorm
        case 96, 99:
            return .thunderstorm // Thunderstorm with hail
        default:
            return .unknown
        }
    }
    
    // Get SF Symbol name for the weather condition
    var systemImageName: String {
        switch self {
        case .clear:
            return "sun.max.fill"
        case .partlyCloudy:
            return "cloud.sun.fill"
        case .cloudy:
            return "cloud.fill"
        case .overcast:
            return "smoke.fill"
        case .fog:
            return "cloud.fog.fill"
        case .drizzle:
            return "cloud.drizzle.fill"
        case .rain:
            return "cloud.rain.fill"
        case .heavyRain:
            return "cloud.heavyrain.fill"
        case .snow:
            return "cloud.snow.fill"
        case .thunderstorm:
            return "cloud.bolt.rain.fill"
        case .unknown:
            return "questionmark.circle.fill"
        }
    }
    
    // Get background gradient colors
    var backgroundGradient: LinearGradient {
        switch self {
        case .clear:
            return LinearGradient(
                colors: [Color.blue.opacity(0.8), Color.yellow.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .partlyCloudy:
            return LinearGradient(
                colors: [Color.blue.opacity(0.6), Color.gray.opacity(0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .cloudy, .overcast:
            return LinearGradient(
                colors: [Color.gray.opacity(0.8), Color.gray.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .fog:
            return LinearGradient(
                colors: [Color.gray.opacity(0.7), Color.white.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .drizzle, .rain, .heavyRain:
            return LinearGradient(
                colors: [Color.gray.opacity(0.9), Color.blue.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .snow:
            return LinearGradient(
                colors: [Color.white.opacity(0.9), Color.blue.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .thunderstorm:
            return LinearGradient(
                colors: [Color.black.opacity(0.8), Color.purple.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .unknown:
            return LinearGradient(
                colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}