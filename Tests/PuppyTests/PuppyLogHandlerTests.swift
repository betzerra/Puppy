import XCTest
import Puppy

final class PuppyLogHandlerTests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }

    func testLoggingSystem() throws {
        #if canImport(Logging)

        // let bool1 = [:].isEmpty         // true
        // let bool2 = ["a": ""].isEmpty   // false
        // let bool3 = ["b": nil].isEmpty  // false

        let consoleLogger: ConsoleLogger = .init("com.example.yourapp.consolelogger.swiftlog", logLevel: .trace)
        var puppy = Puppy()
        puppy.add(consoleLogger)

        LoggingSystem.bootstrap {
            var handler = PuppyLogHandler(label: $0, puppy: puppy)
            handler.logLevel = .trace
            return handler
        }

        var logger: Logger = .init(label: "com.example.yourapp.swiftlog")
        logger.trace("TRACE message using PuppyLogHandler")
        logger.debug("DEBUG message using PuppyLogHandler")
        logger[metadataKey: "keyA"] = "1"
        logger[metadataKey: "keyB"] = "abc"
        logger[metadataKey: "keyC"] = nil
        logger[metadataKey: "keyD"] = "true"
        logger.info("INFO message using PuppyLogHandler")
        let keyD = logger[metadataKey: "keyD"] ?? "keyD is nothing."
        logger.info("\(keyD)")
        logger.notice("NOTICE message using PuppyLogHandler")
        logger.warning("WARNING message using PuppyLogHandler", metadata: ["keyWARNING": "true"])
        logger.error("ERROR message using PuppyLogHandler", metadata: ["keyB": "DEF"])
        logger.critical("CRITICAL message using PuppyLogHandler")

        puppy.remove(consoleLogger)

        #endif // canImport(Logging)
    }

    func testMetadataLogging() throws {
        #if canImport(Logging)
        let consoleLogger: ConsoleLogger = .init(
            "com.example.yourapp.consolelogger.swiftlog",
            logLevel: .trace,
            logFormat: LogFormatter()
        )

        var puppy = Puppy()
        puppy.add(consoleLogger)

        let handler = PuppyLogHandler(label: "", puppy: puppy)

        let lvl3Metadata: Logging.Logger.Metadata = [
            "name": "lvl_3"
        ]

        let lvl2Metadata: Logging.Logger.Metadata = [
            "name": "lvl_2",
            "nested_lvl_3": .dictionary(lvl3Metadata)
        ]

        let lvl1Metadata: Logging.Logger.Metadata = [
            "name": "lvl_1",
            "nested_lvl_2": .dictionary(lvl2Metadata)
        ]

        let rootMetadata: Logging.Logger.Metadata = [
            "name": "root_metadata",
            "nested_lvl_1": .dictionary(lvl1Metadata)
        ]

        handler.log(
            level: .debug,
            message: "Hello World",
            metadata: rootMetadata,
            source: "source",
            file: "file",
            function: "function",
            line: 42
        )
        #endif
    }

    private struct LogFormatter: LogFormattable, Sendable {
        func formatMessage(_ level: LogLevel, message: String, tag: String, function: String, file: String, line: UInt, swiftLogInfo: [String: String], label: String, date: Date, threadID: UInt64) -> String {
            let date = dateFormatter(date, withFormatter: DateFormatter())
            let fileName = fileName(file)
            let moduleName = moduleName(file)
            return "\(date) \(threadID) [\(level.emoji) \(level)] \(swiftLogInfo) \(moduleName)/\(fileName)#L.\(line) \(function) \(message)".colorize(level.color)
        }
    }
}
