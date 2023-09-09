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

        LoggingSystem.bootstrap {
            var handler = PuppyLogHandler(label: $0, puppy: puppy)
            handler.logLevel = .trace
            return handler
        }

        let nestedLvl2Metadata: Logging.Logger.Metadata = [
            "nested_lvl2_foo": "bar"
        ]

        let nestedLvl1Metadata: Logging.Logger.Metadata = [
            "nested_foo": "bar",
            "nested_nested_foo": .dictionary(nestedLvl2Metadata)
        ]

        let metadata: Logging.Logger.Metadata = [
            "foo": .string("bar"),
            "nested": .dictionary(nestedLvl1Metadata)
        ]

        var logger: Logger = .init(label: "com.example.yourapp.swiftlog")
        logger.debug("Hello World", metadata: metadata)
        
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
