import Foundation
import FoundationModels

/// `WeatherTool` provides weather information using the Open-Meteo API.
///
/// This tool can fetch current weather, multi-day forecasts, and hourly forecasts.
/// Uses the free Open-Meteo API (no API key required).
public struct WeatherTool: Tool {

    public let name = "getWeather"

    public let description = """
    Get weather information: current conditions, daily forecast, or hourly forecast.
    Supports any location by city name or coordinates.
    """

    /// Arguments for weather operations
    @Generable
    public struct Arguments: Codable {

        /// Action to perform
        @Guide(description: "Action: 'current', 'forecast', or 'hourly'")
        public var action: String

        /// Location (city name or coordinates)
        @Guide(description: "Location: city name (e.g., 'Paris') or coordinates (e.g., '48.8566,2.3522')")
        public var location: String

        /// Number of forecast days
        @Guide(description: "Number of days for forecast (1-16, default 5)")
        public var days: Int?

        /// Temperature units
        @Guide(description: "Units: 'metric' (Celsius) or 'imperial' (Fahrenheit), default 'metric'")
        public var units: String?

        public init(
            action: String = "",
            location: String = "",
            days: Int? = nil,
            units: String? = nil
        ) {

            self.action = action

            self.location = location

            self.days = days

            self.units = units
        }
    }

    // MARK: - Private Types

    private struct GeocodingResponse: Codable {
        let results: [GeocodingResult]?
    }

    private struct GeocodingResult: Codable {

        let name: String

        let latitude: Double

        let longitude: Double

        let country: String?

        let admin1: String?
    }

    private struct WeatherResponse: Codable {

        let current: CurrentWeather?

        let hourly: HourlyWeather?

        let daily: DailyWeather?

        enum CodingKeys: String, CodingKey {

            case current

            case hourly

            case daily
        }
    }

    private struct CurrentWeather: Codable {

        let time: String

        let temperature2m: Double

        let relativeHumidity2m: Int

        let apparentTemperature: Double

        let weatherCode: Int

        let windSpeed10m: Double

        let windDirection10m: Int

        enum CodingKeys: String, CodingKey {

            case time

            case temperature2m = "temperature_2m"

            case relativeHumidity2m = "relative_humidity_2m"

            case apparentTemperature = "apparent_temperature"

            case weatherCode = "weather_code"

            case windSpeed10m = "wind_speed_10m"

            case windDirection10m = "wind_direction_10m"
        }
    }

    private struct HourlyWeather: Codable {

        let time: [String]

        let temperature2m: [Double]

        let relativeHumidity2m: [Int]

        let weatherCode: [Int]

        let windSpeed10m: [Double]

        enum CodingKeys: String, CodingKey {

            case time

            case temperature2m = "temperature_2m"

            case relativeHumidity2m = "relative_humidity_2m"

            case weatherCode = "weather_code"

            case windSpeed10m = "wind_speed_10m"
        }
    }

    private struct DailyWeather: Codable {

        let time: [String]

        let weatherCode: [Int]

        let temperature2mMax: [Double]

        let temperature2mMin: [Double]

        let precipitationSum: [Double]

        let windSpeed10mMax: [Double]

        enum CodingKeys: String, CodingKey {

            case time

            case weatherCode = "weather_code"

            case temperature2mMax = "temperature_2m_max"

            case temperature2mMin = "temperature_2m_min"

            case precipitationSum = "precipitation_sum"

            case windSpeed10mMax = "wind_speed_10m_max"
        }
    }

    // MARK: - Private Properties

    private static let geocodingBaseURL = "https://geocoding-api.open-meteo.com/v1/search"
    private static let weatherBaseURL = "https://api.open-meteo.com/v1/forecast"

    private static func makeDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        return formatter
    }

    private static func makeTimeFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        formatter.timeZone = TimeZone.current
        return formatter
    }

    // MARK: - Initialization

    public init() {}

    // MARK: - Tool Protocol

    public func call(arguments: Arguments) async throws -> some PromptRepresentable {
        guard !arguments.location.isEmpty else {
            return createErrorOutput(error: WeatherError.missingLocation)
        }

        // Resolve location to coordinates
        let coordinates: (latitude: Double, longitude: Double, name: String)
        do {
            coordinates = try await resolveLocation(arguments.location)
        } catch {
            return createErrorOutput(error: error)
        }

        let isImperial = arguments.units?.lowercased() == "imperial"

        // Route to appropriate action
        switch arguments.action.lowercased() {
        case "current":
            return await fetchCurrentWeather(
                latitude: coordinates.latitude,
                longitude: coordinates.longitude,
                locationName: coordinates.name,
                isImperial: isImperial
            )
        case "forecast":
            let days = min(max(arguments.days ?? 5, 1), 16)
            return await fetchForecast(
                latitude: coordinates.latitude,
                longitude: coordinates.longitude,
                locationName: coordinates.name,
                days: days,
                isImperial: isImperial
            )
        case "hourly":
            return await fetchHourlyForecast(
                latitude: coordinates.latitude,
                longitude: coordinates.longitude,
                locationName: coordinates.name,
                isImperial: isImperial
            )
        default:
            return createErrorOutput(error: WeatherError.invalidAction)
        }
    }

    // MARK: - Private Methods - Location Resolution

    private func resolveLocation(_ location: String) async throws -> (latitude: Double, longitude: Double, name: String) {
        // Check if location is already coordinates (lat,lon format)
        let parts = location.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        if parts.count == 2,
           let lat = Double(parts[0]),
           let lon = Double(parts[1]) {
            return (lat, lon, "(\(String(format: "%.2f", lat)), \(String(format: "%.2f", lon)))")
        }

        // Geocode the location name
        guard var urlComponents = URLComponents(string: Self.geocodingBaseURL) else {
            throw WeatherError.networkError
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "name", value: location),
            URLQueryItem(name: "count", value: "1"),
            URLQueryItem(name: "language", value: "en"),
            URLQueryItem(name: "format", value: "json")
        ]

        guard let url = urlComponents.url else {
            throw WeatherError.networkError
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw WeatherError.networkError
        }

        let geocodingResponse = try JSONDecoder().decode(GeocodingResponse.self, from: data)

        guard let result = geocodingResponse.results?.first else {
            throw WeatherError.locationNotFound
        }

        var locationName = result.name
        if let admin1 = result.admin1 {
            locationName += ", \(admin1)"
        }
        if let country = result.country {
            locationName += ", \(country)"
        }

        return (result.latitude, result.longitude, locationName)
    }

    // MARK: - Private Methods - Weather Fetching

    private func fetchCurrentWeather(
        latitude: Double,
        longitude: Double,
        locationName: String,
        isImperial: Bool
    ) async -> GeneratedContent {
        guard var urlComponents = URLComponents(string: Self.weatherBaseURL) else {
            return createErrorOutput(error: WeatherError.networkError)
        }

        let temperatureUnit = isImperial ? "fahrenheit" : "celsius"
        let windSpeedUnit = isImperial ? "mph" : "kmh"

        urlComponents.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "current", value: "temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m,wind_direction_10m"),
            URLQueryItem(name: "temperature_unit", value: temperatureUnit),
            URLQueryItem(name: "wind_speed_unit", value: windSpeedUnit),
            URLQueryItem(name: "timezone", value: "auto")
        ]

        guard let url = urlComponents.url else {
            return createErrorOutput(error: WeatherError.networkError)
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return createErrorOutput(error: WeatherError.networkError)
            }

            let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)

            guard let current = weatherResponse.current else {
                return createErrorOutput(error: WeatherError.invalidResponse)
            }

            let tempUnit = isImperial ? "°F" : "°C"
            let speedUnit = isImperial ? "mph" : "km/h"
            let condition = weatherCodeToDescription(current.weatherCode)
            let windDirection = degreesToCardinal(current.windDirection10m)

            return GeneratedContent(properties: [
                "status": "success",
                "location": locationName,
                "condition": condition,
                "temperature": "\(String(format: "%.1f", current.temperature2m))\(tempUnit)",
                "feelsLike": "\(String(format: "%.1f", current.apparentTemperature))\(tempUnit)",
                "humidity": "\(current.relativeHumidity2m)%",
                "wind": "\(String(format: "%.1f", current.windSpeed10m)) \(speedUnit) \(windDirection)",
                "message": "Current weather in \(locationName): \(condition), \(String(format: "%.1f", current.temperature2m))\(tempUnit)"
            ])
        } catch {
            return createErrorOutput(error: WeatherError.networkError)
        }
    }

    private func fetchForecast(
        latitude: Double,
        longitude: Double,
        locationName: String,
        days: Int,
        isImperial: Bool
    ) async -> GeneratedContent {
        guard var urlComponents = URLComponents(string: Self.weatherBaseURL) else {
            return createErrorOutput(error: WeatherError.networkError)
        }

        let temperatureUnit = isImperial ? "fahrenheit" : "celsius"
        let windSpeedUnit = isImperial ? "mph" : "kmh"

        urlComponents.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "daily", value: "weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,wind_speed_10m_max"),
            URLQueryItem(name: "temperature_unit", value: temperatureUnit),
            URLQueryItem(name: "wind_speed_unit", value: windSpeedUnit),
            URLQueryItem(name: "timezone", value: "auto"),
            URLQueryItem(name: "forecast_days", value: String(days))
        ]

        guard let url = urlComponents.url else {
            return createErrorOutput(error: WeatherError.networkError)
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return createErrorOutput(error: WeatherError.networkError)
            }

            let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)

            guard let daily = weatherResponse.daily else {
                return createErrorOutput(error: WeatherError.invalidResponse)
            }

            let tempUnit = isImperial ? "°F" : "°C"
            let speedUnit = isImperial ? "mph" : "km/h"

            var forecastDescription = ""
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"

            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium

            for i in 0..<min(daily.time.count, days) {
                let condition = weatherCodeToDescription(daily.weatherCode[i])
                let high = String(format: "%.1f", daily.temperature2mMax[i])
                let low = String(format: "%.1f", daily.temperature2mMin[i])
                let precip = String(format: "%.1f", daily.precipitationSum[i])
                let wind = String(format: "%.1f", daily.windSpeed10mMax[i])

                var dateString = daily.time[i]
                if let date = dateFormatter.date(from: daily.time[i]) {
                    dateString = displayFormatter.string(from: date)
                }

                forecastDescription += "\(dateString): \(condition)\n"
                forecastDescription += "  High: \(high)\(tempUnit), Low: \(low)\(tempUnit)\n"
                forecastDescription += "  Precipitation: \(precip)mm, Wind: \(wind) \(speedUnit)\n\n"
            }

            return GeneratedContent(properties: [
                "status": "success",
                "location": locationName,
                "days": days,
                "forecast": forecastDescription.trimmingCharacters(in: .whitespacesAndNewlines),
                "message": "\(days)-day forecast for \(locationName)"
            ])
        } catch {
            return createErrorOutput(error: WeatherError.networkError)
        }
    }

    private func fetchHourlyForecast(
        latitude: Double,
        longitude: Double,
        locationName: String,
        isImperial: Bool
    ) async -> GeneratedContent {
        guard var urlComponents = URLComponents(string: Self.weatherBaseURL) else {
            return createErrorOutput(error: WeatherError.networkError)
        }

        let temperatureUnit = isImperial ? "fahrenheit" : "celsius"
        let windSpeedUnit = isImperial ? "mph" : "kmh"

        urlComponents.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "hourly", value: "temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m"),
            URLQueryItem(name: "temperature_unit", value: temperatureUnit),
            URLQueryItem(name: "wind_speed_unit", value: windSpeedUnit),
            URLQueryItem(name: "timezone", value: "auto"),
            URLQueryItem(name: "forecast_hours", value: "24")
        ]

        guard let url = urlComponents.url else {
            return createErrorOutput(error: WeatherError.networkError)
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return createErrorOutput(error: WeatherError.networkError)
            }

            let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)

            guard let hourly = weatherResponse.hourly else {
                return createErrorOutput(error: WeatherError.invalidResponse)
            }

            let tempUnit = isImperial ? "°F" : "°C"
            let speedUnit = isImperial ? "mph" : "km/h"

            var hourlyDescription = ""
            let timeFormatter = Self.makeTimeFormatter()
            let displayFormatter = DateFormatter()
            displayFormatter.dateFormat = "EEE HH:mm"

            let hoursToShow = min(hourly.time.count, 24)

            for i in 0..<hoursToShow {
                let condition = weatherCodeToDescription(hourly.weatherCode[i])
                let temp = String(format: "%.1f", hourly.temperature2m[i])
                let humidity = hourly.relativeHumidity2m[i]
                let wind = String(format: "%.1f", hourly.windSpeed10m[i])

                var timeString = hourly.time[i]
                if let date = timeFormatter.date(from: hourly.time[i]) {
                    timeString = displayFormatter.string(from: date)
                }

                hourlyDescription += "\(timeString): \(temp)\(tempUnit), \(condition), "
                hourlyDescription += "Humidity: \(humidity)%, Wind: \(wind) \(speedUnit)\n"
            }

            return GeneratedContent(properties: [
                "status": "success",
                "location": locationName,
                "hours": hoursToShow,
                "hourlyForecast": hourlyDescription.trimmingCharacters(in: .whitespacesAndNewlines),
                "message": "24-hour forecast for \(locationName)"
            ])
        } catch {
            return createErrorOutput(error: WeatherError.networkError)
        }
    }

    // MARK: - Helper Methods

    private func weatherCodeToDescription(_ code: Int) -> String {
        return switch code {
        case 0:

            "Clear sky"
        case 1:

            "Mainly clear"
        case 2:

            "Partly cloudy"
        case 3:

            "Overcast"
        case 45, 48:

            "Foggy"
        case 51, 53, 55:

            "Drizzle"
        case 56, 57:

            "Freezing drizzle"
        case 61, 63, 65:
            "Rain"

        case 66, 67:

            "Freezing rain"
        case 71, 73, 75:

            "Snow"
        case 77:

            "Snow grains"
        case 80, 81, 82:

            "Rain showers"
        case 85, 86:

            "Snow showers"
        case 95:

            "Thunderstorm"
        case 96, 99:

            "Thunderstorm with hail"
        default:

            "Unknown"
        }
    }

    private func degreesToCardinal(_ degrees: Int) -> String {
        let directions = [
            "N",
            "NNE",
            "NE",
            "ENE",
            "E",
            "ESE",
            "SE",
            "SSE",
            "S",
            "SSW",
            "SW",
            "WSW",
            "W",
            "WNW",
            "NW",
            "NNW"
        ]
        let index = Int((Double(degrees) + 11.25) / 22.5) % 16
        return directions[index]
    }

    private func createErrorOutput(error: Error) -> GeneratedContent {
        GeneratedContent(properties: [
            "status": "error",
            "error": error.localizedDescription,
            "message": "Failed to fetch weather information"
        ])
    }
}

// MARK: - Weather Errors

enum WeatherError: Error, LocalizedError {

    case invalidAction

    case missingLocation

    case locationNotFound

    case networkError

    case invalidResponse

    var errorDescription: String? {
        return switch self {
        case .invalidAction:

            "Invalid action. Use 'current', 'forecast', or 'hourly'."
        case .missingLocation:
            
            "Location is required."
        case .locationNotFound:

            "Location not found. Try a different city name or use coordinates."
        case .networkError:

            "Network error. Please check your connection."
        case .invalidResponse:

            "Invalid response from weather service."
        }
    }
}
