//
//  run-server.swift
//  weather-mcp-server
//
//  AI-DRIVEN SWIFT ARCHITECTURE
//

import MCP

/// Entry point for the Weather MCP server.
///
/// Configures the `Server` instance with the `get_weather` tool, wires `ListTools`
/// and `CallTool` method handlers, then starts the server over standard I/O and
/// blocks until the transport is closed.
@main
struct WeatherMCPServer {

    /// Bootstraps and runs the MCP server.
    ///
    /// - Throws: Any error produced during server startup or transport initialisation.
    static func main() async throws {

        let server = Server(
            name: "weather-mcp-server",
            version: "1.0.0",
            capabilities: .init(tools: .init(listChanged: false))
        )

        let weatherTool = WeatherTool()

        /// Responds to `tools/list` by advertising the single `get_weather` tool.
        await server.withMethodHandler(ListTools.self) { _ in
            ListTools.Result(tools: [weatherTool.tool])
        }

        /// Dispatches `tools/call` requests to `WeatherTool.call(arguments:)`.
        /// Unknown tool names are rejected with a JSON-RPC error (-32602).
        await server.withMethodHandler(CallTool.self) { params in
            guard params.name == "get_weather" else {
                throw MCPError.invalidParams("Unknown tool: \(params.name)")
            }
            return try await weatherTool.call(arguments: params.arguments)
        }

        let transport = StdioTransport()
        try await server.start(transport: transport)
        await server.waitUntilCompleted()
    }
}
