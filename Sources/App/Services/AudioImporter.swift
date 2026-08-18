import Foundation
import UniformTypeIdentifiers
import Core

/// Files / Voice Memos import. Proof: AudioImporter, fileImporter.
enum AudioImporter {
    static var allowedTypes: [UTType] {
        var types: [UTType] = [.mpeg4Audio, .mp3, .wav, .aiff]
        if let aac = UTType(filenameExtension: "aac") { types.append(aac) }
        if let caf = UTType(filenameExtension: "caf") { types.append(caf) }
        return types
    }

    static func copyIntoSandbox(from source: URL, destination: URL) throws {
        let accessed = source.startAccessingSecurityScopedResource()
        defer {
            if accessed { source.stopAccessingSecurityScopedResource() }
        }
        if FileManager.default.fileExists(atPath: destination.path) {
            try FileManager.default.removeItem(at: destination)
        }
        try FileManager.default.copyItem(at: source, to: destination)
    }

    static func ext(for url: URL) -> String {
        let ext = url.pathExtension.lowercased()
        if AudioImportTypes.extensions.contains(ext) { return ext }
        return "m4a"
    }
}
