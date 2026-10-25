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

    // MARK: - Roaster / Brand Dictionary
    private let knownRoasters = [
        // Global / Commercial
        "Starbucks", "Peet's Coffee", "Peet's", "Lavazza", "Illy",
        "Nespresso", "Dunkin'", "Dunkin", "Caribou Coffee", "Caribou",
        "Tim Hortons", "Costa Coffee", "Costa", "Folgers", "Cafe Bustelo",
        "Community Coffee", "Death Wish Coffee", "Death Wish", "Eight O'Clock",
        // Artisanal & Specialty
        "Blue Tokai", "Blue Bottle", "Stumptown Coffee", "Stumptown",
        "Intelligentsia", "Counter Culture", "Verve Coffee", "Verve",
        "Onyx Coffee Lab", "Onyx", "Sey Coffee", "Sey", "Tim Wendelboe",
        "Manhattan Coffee Roasters", "Manhattan", "Square Mile", "La Cabra",
        "April Coffee", "Gardelli", "Coffee Collective", "Nomad Coffee", "Nomad",
        "Phil & Sebastian", "Substance Cafe", "Proud Mary", "Methodical Coffee"
    ]

    // MARK: - Famous Known Blends & Roasts (e.g. Starbucks, Peet's, Lavazza)
    private let knownBlends: [String: (origin: String, roast: RoastLevel, notes: [String])] = [
        "Pike Place": ("Latin America", .medium, ["Chocolate", "Toasted Nut", "Smooth Caramel"]),
        "Veranda": ("Latin America", .light, ["Toasted Malt", "Baking Chocolate", "Soft Honey"]),
        "Caffè Verona": ("Multi-Region (Latin America & Asia/Pacific)", .dark, ["Dark Cocoa", "Caramelized Sugar", "Rich"]),
        "Verona": ("Multi-Region (Latin America & Asia/Pacific)", .dark, ["Dark Cocoa", "Caramelized Sugar", "Rich"]),
        "Komodo Dragon": ("Asia-Pacific (Indonesia)", .dark, ["Earthy", "Fresh Herbs", "Warm Spices"]),
        "Espresso Roast": ("Latin America & Asia/Pacific", .dark, ["Rich Molasses", "Dark Caramel", "Steamed Cocoa"]),
        "House Blend": ("Latin America", .medium, ["Toffee", "Roasted Nuts", "Cocoa"]),
        "French Roast": ("Latin America", .dark, ["Smoky", "Intense Dark Cocoa", "Bold"]),
        "Italian Roast": ("Multi-Region", .dark, ["Dark Cocoa", "Roasty Sweetness", "Deep"]),
        "Breakfast Blend": ("Latin America", .light, ["Sweet Orange", "Brown Sugar", "Crisp Apple"]),
        "Siren's Blend": ("Africa & Latin America", .medium, ["Juicy Citrus", "Milk Chocolate", "Floral"]),
        "Green Apron": ("Africa & Latin America", .light, ["Sweet Clementine", "Graham Cracker", "Honey"]),
        "Major Dickason": ("Multi-Region", .dark, ["Full Bodied", "Rich Smoke", "Dark Chocolate"]),
        "Big Bang": ("Latin America & East Africa", .medium, ["Aromatic Citrus", "Sweet Toffee", "Milk Chocolate"]),
        "Qualità Oro": ("Central & South America", .medium, ["Floral", "Fruity", "Honey"]),
        "Super Crema": ("Brazil & South Asia", .medium, ["Hazelnut", "Brown Sugar", "Honey"])
    ]

    // MARK: - Origins & Countries
    private let singleOriginCountries = [
        "Ethiopia", "Colombia", "Kenya", "Guatemala", "Costa Rica",
        "Panama", "Sumatra", "Indonesia", "Brazil", "Rwanda", "Burundi",
        "Honduras", "El Salvador", "Peru", "Mexico", "Vietnam", "India",
        "Jamaica", "Hawaii", "Tanzania", "Uganda", "Nicaragua", "Yemen",
        "Ecuador", "Papua New Guinea", "Congo", "Bolivia", "Madagascar"
    ]

    private let regionalOrigins = [
        "Latin America", "South America", "Central America",
        "Asia-Pacific", "East Africa", "Africa", "Middle East"
    ]

    // MARK: - Comprehensive Flavor Notes Dictionary
    private let flavorDictionary = [
        // Chocolate / Sweet
        "Dark Chocolate", "Milk Chocolate", "Chocolate", "Cocoa", "Cacao",
        "Caramel", "Toffee", "Brown Sugar", "Molasses", "Honey", "Vanilla",
        "Maple", "Graham Cracker", "Butterscotch", "Sweet",
        // Nutty
        "Hazelnut", "Almond", "Walnut", "Pecan", "Toasted Nut", "Nutty", "Peanut",
        // Fruit / Citrus
        "Citrus", "Lemon", "Orange", "Clementine", "Bergamot", "Grapefruit",
        "Apple", "Green Apple", "Red Apple", "Pear", "Peach", "Apricot",
        "Plum", "Nectarine", "Stone Fruit", "Cherry",
        // Berries / Tropical
        "Blackberry", "Blueberry", "Strawberry", "Raspberry", "Currant",
        "Mango", "Pineapple", "Passionfruit", "Papaya", "Lychee", "Fig",
        // Floral & Herbal
        "Jasmine", "Floral", "Rose", "Lavender", "Blossom", "Tea-like",
        "Herbal", "Lemongrass", "Mint",
        // Spice & Earth
        "Cinnamon", "Cardamom", "Nutmeg", "Clove", "Spice", "Earthy",
        "Cedar", "Tobacco", "Smoky", "Rich Smoke"
    ]

    private let knownProcesses = [
        "Washed", "Wet Processed", "Natural", "Dry Processed",
        "Honey", "Anaerobic", "Thermal Shock", "Carbonic Maceration",
        "Wet Hulled", "Double Fermentation", "Swiss Water Decaf", "Decaf"
    ]

    // MARK: - Scan Entrypoint
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

                guard let observations = request.results as? [VNRecognizedTextObservation], !observations.isEmpty else {
                    continuation.resume(throwing: ScannerError.noTextFound)
                    return
                }

                // Sort observations by vertical reading position (top of bag to bottom)
                // Note: Vision Y coordinate is 0 at bottom, 1 at top.
                let sortedObservations = observations.sorted { $0.boundingBox.origin.y > $1.boundingBox.origin.y }
                let lines = sortedObservations.compactMap { observation -> String? in
                    let text = observation.topCandidates(1).first?.string.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard let text, !text.isEmpty, text.count > 1 else { return nil }
                    return text
                }

                guard !lines.isEmpty else {
                    continuation.resume(throwing: ScannerError.noTextFound)
                    return
                }

                let parsed = self.parseCoffeeBagLines(lines)
                continuation.resume(returning: parsed)
            }

            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.recognitionLanguages = ["en-US", "en-GB", "es-ES", "fr-FR", "it-IT", "pt-BR"]

            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: image.cgImageOrientation, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    // MARK: - Intelligent Multi-Stage Parsing
    private func parseCoffeeBagLines(_ lines: [String]) -> ScannedCoffeeBagData {
        let fullText = lines.joined(separator: " ")

        // Stage 1: Detect Roaster / Brand
        var detectedRoaster = ""
        for roaster in knownRoasters {
            if fullText.localizedCaseInsensitiveContains(roaster) {
                detectedRoaster = roaster
                break
            }
        }

        // If not in known list, take the first clean prominent line that looks like a brand name
        if detectedRoaster.isEmpty {
            for line in lines.prefix(3) {
                let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                if !isNoiseLine(trimmed) && trimmed.count >= 3 && trimmed.count <= 26 {
                    detectedRoaster = trimmed
                    break
                }
            }
        }

        if detectedRoaster.isEmpty {
            detectedRoaster = "Coffee Roasters"
        }

        // Stage 2: Check for Famous Known Blends (e.g. Starbucks Pike Place, Verona, Veranda)
        var matchedBlendInfo: (origin: String, roast: RoastLevel, notes: [String])?
        var detectedBeanName = ""

        for (blendKey, info) in knownBlends {
            if fullText.localizedCaseInsensitiveContains(blendKey) {
                detectedBeanName = "\(blendKey) Roast"
                matchedBlendInfo = info
                break
            }
        }

        // Stage 3: Detect Roast Level
        var detectedRoast: RoastLevel = .medium
        let lowerText = fullText.lowercased()

        if lowerText.contains("blonde") || lowerText.contains("light roast") || lowerText.contains("cinnamon") || lowerText.contains("filter roast") {
            detectedRoast = .light
        } else if lowerText.contains("extra dark") || lowerText.contains("french roast") || lowerText.contains("italian roast") || lowerText.contains("dark roast") || lowerText.contains("espresso roast") || lowerText.contains("bold") {
            detectedRoast = .dark
        } else if lowerText.contains("medium-dark") || lowerText.contains("medium dark") || lowerText.contains("full city") || lowerText.contains("vienna") {
            detectedRoast = .mediumDark
        } else if lowerText.contains("medium roast") || lowerText.contains("medium") || lowerText.contains("city roast") {
            detectedRoast = .medium
        } else if let matched = matchedBlendInfo {
            detectedRoast = matched.roast
        }

        // Stage 4: Detect Origin
        var detectedOrigin = ""
        for country in singleOriginCountries {
            if fullText.localizedCaseInsensitiveContains(country) {
                detectedOrigin = country
                break
            }
        }

        if detectedOrigin.isEmpty {
            for region in regionalOrigins {
                if fullText.localizedCaseInsensitiveContains(region) {
                    detectedOrigin = region
                    break
                }
            }
        }

        if detectedOrigin.isEmpty, let matched = matchedBlendInfo {
            detectedOrigin = matched.origin
        }

        if detectedOrigin.isEmpty {
            // Check if bag says "Blend" or "House"
            if lowerText.contains("blend") {
                detectedOrigin = "House Blend"
            } else {
                detectedOrigin = "Artisanal Blend"
            }
        }

        // Stage 5: Detect Process
        var detectedProcess = ""
        for process in knownProcesses {
            if fullText.localizedCaseInsensitiveContains(process) {
                detectedProcess = process
                break
            }
        }

        if detectedProcess.isEmpty {
            if lowerText.contains("decaf") {
                detectedProcess = "Swiss Water Decaf"
            } else if lowerText.contains("espresso") {
                detectedProcess = "Espresso Processed"
            } else if lowerText.contains("blend") {
                detectedProcess = "Washed & Natural Blend"
            } else {
                detectedProcess = "Traditional Washed"
            }
        }

        // Stage 6: Detect Elevation
        var detectedElevation = 0
        if let match = fullText.range(of: #"\b(1[0-9]\d{2}|2[0-5]\d{2})\s*(m|masl|meters)?\b"#, options: .regularExpression) {
            let numString = String(fullText[match]).components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            if let elev = Int(numString), elev >= 900 && elev <= 2600 {
                detectedElevation = elev
            }
        }
        if detectedElevation == 0 {
            // Assign realistic elevation according to origin
            if detectedOrigin.localizedCaseInsensitiveContains("Ethiopia") || detectedOrigin.localizedCaseInsensitiveContains("Kenya") {
                detectedElevation = 1950
            } else if detectedOrigin.localizedCaseInsensitiveContains("Colombia") || detectedOrigin.localizedCaseInsensitiveContains("Guatemala") {
                detectedElevation = 1650
            } else {
                detectedElevation = 1450
            }
        }

        // Stage 7: Detect Flavor Notes dynamically from text
        var detectedNotes: [String] = []
        for note in flavorDictionary {
            if fullText.localizedCaseInsensitiveContains(note) && !detectedNotes.contains(note) {
                detectedNotes.append(note)
            }
        }

        // If no explicit tasting notes were printed on the bag, use the matched blend or roast profile
        if detectedNotes.isEmpty {
            if let matched = matchedBlendInfo {
                detectedNotes = matched.notes
            } else {
                switch detectedRoast {
                case .light:
                    detectedNotes = ["Crisp Citrus", "Soft Honey", "Toasted Almond"]
                case .medium:
                    detectedNotes = ["Milk Chocolate", "Toasted Pecan", "Caramel"]
                case .mediumDark:
                    detectedNotes = ["Dark Cocoa", "Brown Sugar", "Roasted Hazelnut"]
                case .dark:
                    detectedNotes = ["Dark Cocoa", "Roasty Sweetness", "Smoky Toffee"]
                }
            }
        }

        // Stage 8: Extract or Refine Bean Name
        if detectedBeanName.isEmpty {
            // Find the most descriptive non-noise line that isn't the roaster
            for line in lines {
                let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.localizedCaseInsensitiveContains(detectedRoaster) { continue }
                if isNoiseLine(trimmed) { continue }

                // Check if this line contains the origin or common coffee title words
                if trimmed.localizedCaseInsensitiveContains(detectedOrigin) ||
                    trimmed.localizedCaseInsensitiveContains("Roast") ||
                    trimmed.localizedCaseInsensitiveContains("Blend") ||
                    trimmed.localizedCaseInsensitiveContains("Selection") ||
                    trimmed.localizedCaseInsensitiveContains("Reserve") {
                    detectedBeanName = trimmed
                    break
                }
            }
        }

        if detectedBeanName.isEmpty {
            // Pick the first clean line below roaster
            for line in lines {
                let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.localizedCaseInsensitiveContains(detectedRoaster) { continue }
                if isNoiseLine(trimmed) { continue }
                if trimmed.count >= 4 && trimmed.count <= 35 {
                    detectedBeanName = trimmed
                    break
                }
            }
        }

        if detectedBeanName.isEmpty {
            detectedBeanName = "\(detectedRoaster) \(detectedOrigin)"
        }

        // Stage 9: Detect Roast Date
        var detectedDate = Calendar.current.date(byAdding: .day, value: -12, to: Date()) ?? Date()
        let datePatterns = [
            #"\b(0?[1-9]|1[0-2])[\/\.-](0?[1-9]|[12]\d|3[01])[\/\.-](20\d{2}|\d{2})\b"#,
            #"\b(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+(\d{1,2}),?\s+(20\d{2})\b"#
        ]
        for pattern in datePatterns {
            if let match = fullText.range(of: pattern, options: [.regularExpression, .caseInsensitive]) {
                let dateStr = String(fullText[match])
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                if let parsedDate = formatter.date(from: dateStr) {
                    detectedDate = parsedDate
                    break
                }
            }
        }

        return ScannedCoffeeBagData(
            beanName: detectedBeanName,
            roaster: detectedRoaster,
            origin: detectedOrigin,
            elevationMeters: detectedElevation,
            process: detectedProcess,
            roastLevel: detectedRoast,
            flavorNotes: Array(detectedNotes.prefix(4)),
            roastDate: detectedDate,
            rawTextLines: lines
        )
    }

    private func isNoiseLine(_ text: String) -> Bool {
        let lower = text.lowercased()
        if lower.contains("net wt") || lower.contains("12 oz") || lower.contains("16 oz") ||
            lower.contains("250 g") || lower.contains("250g") || lower.contains("340g") || lower.contains("500g") || lower.contains("1kg") ||
            lower.contains("whole bean") || lower.contains("ground coffee") || lower.contains("100% arabica") ||
            lower.contains("certified organic") || lower.contains("fair trade") || lower.contains("usda organic") ||
            lower.contains("roasted by") || lower.contains("packaged by") || lower.contains("barcode") ||
            lower.allSatisfy({ $0.isNumber || $0.isPunctuation || $0.isWhitespace }) {
            return true
        }
        return false
    }

    enum ScannerError: LocalizedError {
        case invalidImage
        case noTextFound

        var errorDescription: String? {
            switch self {
            case .invalidImage:
                return "The captured image could not be processed."
            case .noTextFound:
                return "No readable text detected on the coffee bag. Try taking a closer, well-lit photo of the label."
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
