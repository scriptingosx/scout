import ArgumentParser
import Scout
import Foundation

struct AddCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "add",
        abstract: "Add value at a given path",
        discussion: "To find examples and advanced explanations, please type `scout doc add`")

    @Argument(help: PathAndValue.help)
    var pathsAndValues = [PathAndValue]()

    @Option(name: [.short, .customLong("input")], help: "A file path from which to read the data")
    var inputFilePath: String?

    @Option(name: [.short, .long], help: "Write the modified data into the file at the given path")
    var output: String?

    @Option(name: [.short, .customLong("modify")], help: "Read and write the data into the same file at the given path")
    var modifyFilePath: String?

    @Flag(name: [.short, .long], inversion: .prefixedNo, help: "Output the modified data")
    var verbose = false

    @Flag(name: [.long], inversion: .prefixedNo, help: "Colorise the ouput")
    var color = true

    func run() throws {

        do {
            if let filePath = modifyFilePath ?? inputFilePath {
                let data = try Data(contentsOf: URL(fileURLWithPath: filePath.replacingTilde))
                try add(from: data)
            } else {
                let streamInput = FileHandle.standardInput.readDataToEndOfFile()
                try add(from: streamInput)
            }
        } catch let error as PathExplorerError {
            print(error.commandLineErrorDescription)
            return
        }
    }

    func add(from data: Data) throws {
        let output = modifyFilePath ?? self.output

        if var json = try? PathExplorerFactory.make(Json.self, from: data) {

            try add(pathsAndValues, to: &json)
            try ScoutCommand.output(output, dataWith: json, verbose: verbose, colorise: color)

        } else if var plist = try? PathExplorerFactory.make(Plist.self, from: data) {

            try add(pathsAndValues, to: &plist)
            try ScoutCommand.output(output, dataWith: plist, verbose: verbose, colorise: color)

        } else if var xml = try? PathExplorerFactory.make(Xml.self, from: data) {

            try add(pathsAndValues, to: &xml)
            try ScoutCommand.output(output, dataWith: xml, verbose: verbose, colorise: color)

        } else {
            if let filePath = inputFilePath {
                throw RuntimeError.unknownFormat("The format of the file at \(filePath) is not recognized")
            } else {
                throw RuntimeError.unknownFormat("The format of the input stream is not recognized")
            }
        }
    }

    func add<Explorer: PathExplorer>(_ pathsAndValues: [PathAndValue], to explorer: inout Explorer) throws {
        try pathsAndValues.forEach { pathAndValue in
            let (path, value) = (pathAndValue.readingPath, pathAndValue.value)

            if let forceType = pathAndValue.forceType {
                switch forceType {
                case .string: try explorer.add(value, at: path, as: .string)
                case .real: try explorer.add(value, at: path, as: .real)
                case .int: try explorer.add(value, at: path, as: .int)
                case .bool: try explorer.add(value, at: path, as: .bool)
                }
            } else {
                try explorer.add(value, at: path)
            }
        }
    }
}
