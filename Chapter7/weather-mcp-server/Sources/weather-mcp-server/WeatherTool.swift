//
//  WeatherTool.swift
//  weather-mcp-server
//
//  AI-DRIVEN SWIFT ARCHITECTURE
//

import Foundation
import MCP

// MARK: - Private response model

/// Maps the top-level JSON object returned by the OpenWeatherMap `/data/2.5/weather` endpoint.
private struct OpenWeatherResponse: Decodable {

    /// Temperature and humidity data nested under the `main` key.
    struct Main: Decodable {
        /// Current temperature in degrees Celsius (metric units).
        let temp: Double
        /// Relative humidity as a percentage (0–100).
        let humidity: Int
    }

    /// A single weather condition entry from the `weather` array.
    struct WeatherCondition: Decodable {
        /// Human-readable condition string, e.g. "clear sky" or "light rain".
        let description: String
    }

    /// City name as returned by the API (may differ from the query if resolved to a canonical form).
    let name: String
    /// Core atmospheric measurements.
    let main: Main
    /// Array of weather condition descriptors; the first element is used as the primary condition.
    let weather: [WeatherCondition]
}

// MARK: - Private output model

/// The structured payload returned to the MCP client as pretty-printed JSON.
private struct WeatherResult: Encodable {
    /// Canonical city name as resolved by the API.
    let city: String
    /// Current temperature in degrees Celsius.
    let temperature: Double
    /// Primary weather condition description.
    let description: String
    /// Relative humidity as a percentage.
    let humidity: Int
}

// MARK: - Tool

/// Encapsulates the `get_weather` MCP tool definition and its execution logic.
///
/// `WeatherTool` is a value type (`Sendable`) that can be shared safely across
/// Swift concurrency contexts without additional synchronization.
struct WeatherTool: Sendable {

    /// The MCP tool descriptor advertised to clients via `tools/list`.
    ///
    /// Declared as a stored `let` so the `Tool` value is allocated once and reused
    /// on every `ListTools` request.
    let tool: Tool = Tool(
        name: "get_weather",
        description: "Get current weather for a city using the OpenWeatherMap API.",
        inputSchema: .object([
            "properties": .object([
                "city": .string("City name, e.g. Paris")
            ]),
            "required": .array([.string("city")])
        ])
    )

    /// Executes the weather lookup for the given MCP tool call arguments.
    ///
    /// - Parameter arguments: Key-value pairs supplied by the client. Must contain `"city"`.
    /// - Returns: A `CallTool.Result` whose `content` is either pretty-printed JSON
    ///   on success or an error message with `isError: true` on failure.
    /// - Throws: `MCPError.invalidParams` when the required `city` argument is absent or empty,
    ///   which causes the MCP layer to respond with a JSON-RPC error (-32602).
    func call(arguments: [String: Value]?) async throws -> CallTool.Result {

        // 1. Validate required city parameter
        guard let city = arguments?["city"]?.stringValue, !city.isEmpty else {
            throw MCPError.invalidParams("Missing required parameter 'city'")
        }

        // 2. Validate API key from environment
        guard let apiKey = ProcessInfo.processInfo.environment["OPENWEATHER_API_KEY"],
              !apiKey.isEmpty else {
            return CallTool.Result(
                content: [.text("Error: OPENWEATHER_API_KEY environment variable is not set.")],
                isError: true
            )
        }

        // 3. Build URL using URLComponents (handles percent-encoding automatically)
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        components.path = "/data/2.5/weather"
        components.queryItems = [
            URLQueryItem(name: "q",     value: city),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric")
        ]

        guard let url = components.url else {
            return CallTool.Result(
                content: [.text("Error: Could not construct API URL for city '\(city)'.")],
                isError: true
            )
        }

        // 4. Perform async network request
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(from: url)
        } catch {
            return CallTool.Result(
                content: [.text("Error: Network request failed – \(error.localizedDescription)")],
                isError: true
            )
        }

        // 5. Check HTTP status
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            let body = String(data: data, encoding: .utf8) ?? "<empty body>"
            return CallTool.Result(
                content: [.text("Error: OpenWeatherMap returned HTTP \(httpResponse.statusCode). Body: \(body)")],
                isError: true
            )
        }

        // 6. Decode OpenWeatherMap JSON
        let weatherResponse: OpenWeatherResponse
        do {
            weatherResponse = try JSONDecoder().decode(OpenWeatherResponse.self, from: data)
        } catch {
            return CallTool.Result(
                content: [.text("Error: Failed to decode weather response – \(error.localizedDescription)")],
                isError: true
            )
        }

        // 7. Encode result as pretty-printed JSON
        let result = WeatherResult(
            city: weatherResponse.name,
            temperature: weatherResponse.main.temp,
            description: weatherResponse.weather.first?.description ?? "unknown",
            humidity: weatherResponse.main.humidity
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        guard let jsonData = try? encoder.encode(result),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return CallTool.Result(
                content: [.text("Error: Failed to encode weather result as JSON.")],
                isError: true
            )
        }

        return CallTool.Result(
            content: [.text(jsonString)],
            isError: false
        )
    }
}
