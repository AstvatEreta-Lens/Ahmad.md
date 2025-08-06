import Foundation

// MARK: - Main Weather Response
struct WeatherResponse: Codable {
    let latitude: Double
    let longitude: Double
    let generationtimeMs: Double
    let utcOffsetSeconds: Int
    let timezone: String
    let timezoneAbbreviation: String
    let elevation: Double
    let currentUnits: CurrentUnits
    let current: CurrentWeather
    let dailyUnits: DailyUnits
    let daily: DailyWeather
    
    enum CodingKeys: String, CodingKey {
        case latitude, longitude, timezone, elevation
        case generationtimeMs = "generationtime_ms"
        case utcOffsetSeconds = "utc_offset_seconds"
        case timezoneAbbreviation = "timezone_abbreviation"
        case currentUnits = "current_units"
        case current
        case dailyUnits = "daily_units"
        case daily
    }
}

// MARK: - Current Weather Units
struct CurrentUnits: Codable {
    let time: String
    let interval: String
    let temperature2m: String
    let weatherCode: String
    
    enum CodingKeys: String, CodingKey {
        case time, interval
        case temperature2m = "temperature_2m"
        case weatherCode = "weather_code"
    }
}

// MARK: - Current Weather Data
struct CurrentWeather: Codable {
    let time: String
    let interval: Int
    let temperature2m: Double
    let weatherCode: Int
    
    enum CodingKeys: String, CodingKey {
        case time, interval
        case temperature2m = "temperature_2m"
        case weatherCode = "weather_code"
    }
}

// MARK: - Daily Weather Units
struct DailyUnits: Codable {
    let time: String
    let weatherCode: String
    let temperature2mMax: String
    let temperature2mMin: String
    
    enum CodingKeys: String, CodingKey {
        case time
        case weatherCode = "weather_code"
        case temperature2mMax = "temperature_2m_max"
        case temperature2mMin = "temperature_2m_min"
    }
}

// MARK: - Daily Weather Data
struct DailyWeather: Codable {
    let time: [String]
    let weatherCode: [Int]
    let temperature2mMax: [Double]
    let temperature2mMin: [Double]
    
    enum CodingKeys: String, CodingKey {
        case time
        case weatherCode = "weather_code"
        case temperature2mMax = "temperature_2m_max"
        case temperature2mMin = "temperature_2m_min"
    }
}