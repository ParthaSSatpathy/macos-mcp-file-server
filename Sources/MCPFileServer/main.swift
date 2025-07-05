import MCP
import ServiceLifecycle
import Logging
import Foundation

// Create service implementation
struct MCPFileServerService: Service {
    let server: Server
    let transport: Transport
    let logger: Logger
    
    func run() async throws {
        logger.info("Starting MCP File Server...")
        
        // Start the server with an initialize hook
        try await server.start(transport: transport) { clientInfo, clientCapabilities in
            logger.info("Client connected: \(clientInfo.name) v\(clientInfo.version)")
            
            // Log that client connected successfully
            logger.info("Client capabilities received")
        }
        
        logger.info("MCP Server is running and ready for connections")
        
        // Keep running until cancelled
        try await withTaskCancellationHandler {
            // Sleep indefinitely - the service will be cancelled on shutdown signals
            while !Task.isCancelled {
                try await Task.sleep(for: .seconds(1))
            }
        } onCancel: {
            logger.info("Received cancellation signal")
        }
    }
    
    func shutdown() async throws {
        logger.info("Shutting down MCP File Server...")
        await server.stop()
        logger.info("Server stopped")
    }
}

@main
struct Main {
    static func main() async throws {
        // Configure logging - Use stderr for MCP servers (stdout is reserved for MCP protocol)
        LoggingSystem.bootstrap { label in
            var handler = StreamLogHandler.standardError(label: label)
            handler.logLevel = .info  // Changed to .info to reduce noise
            return handler
        }

        let logger = Logger(label: "com.example.mcp-file-server")

        // Create the MCP server
        let server = Server(
            name: "macOS MCP File Server",
            version: "1.0.0",
            capabilities: .init(
                tools: .init(listChanged: true)
            )
        )

        // Register tool list handler
        await server.withMethodHandler(ListTools.self) { _ in
            let tools = [
                Tool(
                    name: "hello",
                    description: "A simple hello world tool",
                    inputSchema: .object([
                        "properties": .object([
                            "name": .object([
                                "type": .string("string"),
                                "description": .string("Name to greet")
                            ])
                        ])
                    ])
                ),
                Tool(
                    name: "get_current_time",
                    description: "Get the current date and time",
                    inputSchema: .object([:])  // No parameters needed
                )
            ]
            return .init(tools: tools)
        }

        // Register tool call handler
        await server.withMethodHandler(CallTool.self) { params in
            switch params.name {
            case "hello":
                let name = params.arguments?["name"]?.stringValue ?? "World"
                return .init(content: [.text("Hello, \(name)! This message is from your macOS MCP File Server.")], isError: false)
            case "get_current_time":
                let formatter = DateFormatter()
                formatter.dateStyle = .full
                formatter.timeStyle = .full
                let currentTime = formatter.string(from: Date())
                return .init(content: [.text("Current time: \(currentTime)")], isError: false)
            default:
                return .init(content: [.text("Unknown tool: \(params.name)")], isError: true)
            }
        }

        // Create transport and service
        let transport = StdioTransport(logger: logger)
        let service = MCPFileServerService(server: server, transport: transport, logger: logger)
        
        // Create service group with graceful shutdown
        let serviceGroup = ServiceGroup(
            services: [service],
            gracefulShutdownSignals: [.sigterm, .sigint],
            logger: logger
        )
        
        // Run the service - this will block until shutdown
        try await serviceGroup.run()
    }
}