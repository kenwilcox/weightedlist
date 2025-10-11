import Foundation

func usage(_ program: String) {
    FileHandle.standardError.write(Data("Usage: \(program) <directory>\n".utf8))
}

func isDirectory(_ url: URL) -> Bool {
    var isDir: ObjCBool = false
    let exists = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
    return exists && isDir.boolValue
}

func listTxtFiles(in dir: URL) throws -> [URL] {
    let contents = try FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil, options: [.skipsSubdirectoryDescendants, .skipsHiddenFiles])
    return contents.filter { url in
        url.hasDirectoryPath == false && url.pathExtension.lowercased() == "txt"
    }
}

//@main
struct WeightedListApp {
    static func main() {
        let args = CommandLine.arguments
        let program = (args.first as NSString?)?.lastPathComponent ?? "weighted-list"
        guard args.count == 2 else {
            usage(program)
            exit(1)
        }
        let dirPath = args[1]
        let dirURL = URL(fileURLWithPath: dirPath)
        guard isDirectory(dirURL) else {
            FileHandle.standardError.write(Data("Error: not a directory: \(dirPath)\n".utf8))
            exit(1)
        }

        // Maps: line -> count, and line -> distinct base names set
        var lineCount: [String: Int] = [:]
        var lineToNames: [String: Set<String>] = [:]

        do {
            let files = try listTxtFiles(in: dirURL)
            for fileURL in files {
                let baseName = fileURL.deletingPathExtension().lastPathComponent
                // Read as bytes, then decode as UTF-8 lossily similar to Rust's from_utf8_lossy
                let data = try Data(contentsOf: fileURL)
                let content = String(decoding: data, as: UTF8.self)

                // Split on "\n" preserving empty subsequences, then drop a single trailing empty if present
                var rawLines = content.split(separator: "\n", omittingEmptySubsequences: false).map { String($0) }
                if let last = rawLines.last, last.isEmpty {
                    rawLines.removeLast()
                }

                for var line in rawLines {
                    // Strip trailing CR to handle Windows CRLF
                    if line.hasSuffix("\r") {
                        line.removeLast()
                    }
                    lineCount[line, default: 0] += 1
                    var names = lineToNames[line] ?? Set<String>()
                    names.insert(baseName)
                    lineToNames[line] = names
                }
            }
        } catch {
            FileHandle.standardError.write(Data("Error reading directory or files: \(error)\n".utf8))
            exit(2)
        }

        // Sort lines by count desc, then by line asc
        let sortedItems = lineCount.map { ($0.key, $0.value) }
            .sorted { (a, b) -> Bool in
                if a.1 != b.1 { return a.1 > b.1 }
                return a.0 < b.0
            }

        for (line, count) in sortedItems {
            let names = Array(lineToNames[line] ?? []).sorted()
            let namesJoined = names.joined(separator: ", ")
            print("\(count) - \(line) (\(namesJoined))")
        }
    }
}
