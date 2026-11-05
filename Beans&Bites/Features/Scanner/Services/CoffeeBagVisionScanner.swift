//
//  CoffeeBagVisionScanner.swift
//  Beans&Bites
//

import Foundation
import UIKit
import Vision

struct ScannedCoffeeBagData {
    var beanName: String
    var roaster: String
    var origin: String
    var elevationMeters: Int
    var process: String
    var roastLevel: RoastLevel
    var flavorNotes: [String]
    var roastDate: Date
    var rawTextLines: [String]
}

final class CoffeeBagVisionScanner {
    static let shared = CoffeeBagVisionScanner()

    private let knownOrigins = [
        "Ethiopia", "Colombia", "Kenya", "Guatemala", "Costa Rica",
        "Panama", "Rwanda", "Burundi", "Honduras", "El Salvador",
        "Brazil", "Indonesia", "Yemen", "Peru", "Ecuador", "Mexico"
    ]

    private let knownRoasters = [
        "Onyx Coffee Lab", "Onyx", "Blue Bottle", "Sey Coffee", "Sey",
        "Tim Wendelboe", "Manhattan Coffee", "Manhattan", "Square Mile",
        "Counter Culture", "Verve", "Intelligentsia", "La Cabra",
        "April Coffee", "Gardelli", "Coffee Collective", "Nomad"
    ]

    private let knownProcesses = [
        "Washed", "Natural", "Honey", "Anaerobic", "Thermal Shock",
        "Carbonic Maceration", "Wet Hulled", "Double Fermentation"
    ]

    private let potentialNotes = [
        "Jasmine", "Bergamot", "Peach", "Blackberry", "Citrus",
        "Dark Chocolate", "Milk Chocolate", "Caramel", "Honey", "Strawberry",
        "Lychee", "Rose", "Vanilla", "Almond", "Floral", "Green Apple",
        "Apricot", "Orange", "Cacao", "Nutmeg", "Cinnamon"
    ]

    func scanImage(_ image: UIImage) async throws -> ScannedCoffeeBagData {
        guard let cgImage = image.cgImage else {
            throw ScannerError.invalidImage
        }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { [weak self] request, error in
                guard let self = self else { return }

                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(throwing: ScannerError.noTextFound)
                    return
                }

                let lines = observations.compactMap { $0.topCandidates(1).first?.string }
                let parsed = self.parseCoffeeBagLines(lines)
                continuation.resume(returning: parsed)
            }

            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: image.cgImageOrientation, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    private func parseCoffeeBagLines(_ lines: [String]) -> ScannedCoffeeBagData {
        var detectedRoaster = "Specialty Roaster"
        var detectedOrigin = "Ethiopia"
        var detectedProcess = "Washed"
        var detectedRoast: RoastLevel = .medium
        var detectedElevation = 1850
        var detectedNotes: [String] = []
        var detectedName = ""
        var detectedDate = Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date()

        let fullText = lines.joined(separator: " ")

        // 1. Detect Roaster
        for roaster in knownRoasters {
            if fullText.localizedCaseInsensitiveContains(roaster) {
                detectedRoaster = roaster
                break
            }
        }
        if detectedRoaster == "Specialty Roaster", let firstLine = lines.first, firstLine.count < 30 {
            detectedRoaster = firstLine
        }

        // 2. Detect Origin
        for origin in knownOrigins {
            if fullText.localizedCaseInsensitiveContains(origin) {
                detectedOrigin = origin
                break
            }
        }

        // 3. Detect Process
        for process in knownProcesses {
            if fullText.localizedCaseInsensitiveContains(process) {
                detectedProcess = process
                break
            }
        }

        // 4. Detect Roast Level
        if fullText.localizedCaseInsensitiveContains("Light") || fullText.localizedCaseInsensitiveContains("Filter") {
            detectedRoast = .light
        } else if fullText.localizedCaseInsensitiveContains("Dark") || fullText.localizedCaseInsensitiveContains("French") {
            detectedRoast = .dark
        } else if fullText.localizedCaseInsensitiveContains("Medium Dark") {
            detectedRoast = .mediumDark
        } else {
            detectedRoast = .medium
        }

        // 5. Detect Elevation (e.g. 1950m or 2100 masl)
        if let match = fullText.range(of: #"\b(1[2-9]\d{2}|2[0-5]\d{2})\s*(m|masl|meters)?\b"#, options: .regularExpression) {
            let numString = String(fullText[match]).components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            if let elev = Int(numString), elev >= 800 && elev <= 2600 {
                detectedElevation = elev
            }
        }

        // 6. Detect Flavor Notes
        for note in potentialNotes {
            if fullText.localizedCaseInsensitiveContains(note) {
                detectedNotes.append(note)
            }
        }

        // 7. Detect Bean Name
        // Usually the line after the roaster or containing origin/region
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.localizedCaseInsensitiveContains(detectedOrigin) ||
                trimmed.localizedCaseInsensitiveContains("Yirgacheffe") ||
                trimmed.localizedCaseInsensitiveContains("Geisha") ||
                trimmed.localizedCaseInsensitiveContains("Huila") ||
                trimmed.localizedCaseInsensitiveContains("Sidama") ||
                trimmed.localizedCaseInsensitiveContains("Bourbon") {
                detectedName = trimmed
                break
            }
        }

        if detectedName.isEmpty {
            detectedName = "\(detectedOrigin) Single Origin"
        }

        return ScannedCoffeeBagData(
            beanName: detectedName,
            roaster: detectedRoaster,
            origin: detectedOrigin,
            elevationMeters: detectedElevation,
            process: detectedProcess,
            roastLevel: detectedRoast,
            flavorNotes: detectedNotes.isEmpty ? ["Stone Fruit", "Honey", "Citrus"] : detectedNotes,
            roastDate: detectedDate,
            rawTextLines: lines
        )
    }

    enum ScannerError: LocalizedError {
        case invalidImage
        case noTextFound

        var errorDescription: String? {
            switch self {
            case .invalidImage:
                return "The captured image could not be processed."
            case .noTextFound:
                return "No readable text detected on the coffee bag."
            }
        }
    }
}

private extension UIImage {
    var cgImageOrientation: CGImagePropertyOrientation {
        switch imageOrientation {
        case .up: return .up
        case .down: return .down
        case .left: return .left
        case .right: return .right
        case .upMirrored: return .upMirrored
        case .downMirrored: return .downMirrored
        case .leftMirrored: return .leftMirrored
        case .rightMirrored: return .rightMirrored
        @unknown default: return .up
        }
    }
}
