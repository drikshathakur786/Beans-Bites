//
//  CoffeeBagScannerView.swift
//  Beans&Bites
//

import SwiftUI
import SwiftData
import PhotosUI
import UIKit

struct CoffeeBagScannerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var isScanning = false
    @State private var scanlineOffset: CGFloat = -140
    @State private var scannedData: ScannedCoffeeBagData?
    @State private var scannedImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    @State private var showCameraPicker = false
    @State private var cameraImage: UIImage?
    @State private var errorMessage: String?
    @State private var didSaveSuccess = false
    @State private var showRawText = false

    // Editable fields for user verification
    @State private var editName = ""
    @State private var editRoaster = ""
    @State private var editOrigin = ""
    @State private var editProcess = ""
    @State private var editElevation = 1450
    @State private var editRoast: RoastLevel = .medium
    @State private var editNotes: [String] = []

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Top guidance
                        VStack(spacing: 6) {
                            Text("Scan Coffee Bag")
                                .font(.title2.weight(.bold))
                                .foregroundStyle(.white)

                            Text("Apple Vision OCR extracts roaster, blend name, origin, process, and tasting notes automatically.")
                                .font(.caption)
                                .foregroundStyle(Color.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }
                        .padding(.top, 16)

                        // Error Banner if needed
                        if let error = errorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(CoffeeTheme.accentWarmGold)
                                Text(error)
                                    .font(.caption)
                                    .foregroundStyle(.white)
                                Spacer()
                                Button {
                                    errorMessage = nil
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.caption2)
                                        .foregroundStyle(.white.opacity(0.6))
                                }
                            }
                            .padding(12)
                            .background(Color.red.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red.opacity(0.3), lineWidth: 1))
                            .padding(.horizontal, 20)
                        }

                        // Reticle Camera Viewfinder
                        viewfinderBox
                            .frame(maxWidth: 320, maxHeight: scannedData == nil ? 280 : 180)
                            .padding(.vertical, 4)

                        // Results or Action Controls
                        if scannedData != nil {
                            scannedResultCard
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        } else {
                            controlButtons
                        }

                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        await processImage(uiImage)
                    }
                }
            }
            .sheet(isPresented: $showCameraPicker) {
                CameraPickerRepresentable(image: $cameraImage)
            }
            .onChange(of: cameraImage) { _, newImage in
                if let img = newImage {
                    Task {
                        await processImage(img)
                    }
                }
            }
            .onAppear {
                startScanlineAnimation()
            }
        }
    }

    // MARK: - Viewfinder Box with Animated Laser Scanline
    private var viewfinderBox: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.15), lineWidth: 1.5)
                .background(Color.white.opacity(0.04))

            // 4 Corner Brackets (Apple Barcode Scanner Style)
            cornerBrackets

            // Center coffee bag icon watermark
            Image(systemName: "shippingbox.and.arrow.backward.fill")
                .font(.system(size: 48))
                .foregroundStyle(CoffeeTheme.accentWarmGold.opacity(0.2))

            // Animated Laser Scanline
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            CoffeeTheme.accentWarmGold.opacity(0.8),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 3)
                .offset(y: scanlineOffset)

            if isScanning {
                VStack(spacing: 8) {
                    ProgressView()
                        .tint(CoffeeTheme.accentWarmGold)
                    Text("Reading Coffee Label via Apple Vision...")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(CoffeeTheme.accentWarmGold)
                }
                .padding(16)
                .background(Color.black.opacity(0.75))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var cornerBrackets: some View {
        GeometryReader { geo in
            let length: CGFloat = 26
            let thickness: CGFloat = 3.5
            let cornerRadius: CGFloat = 16

            Path { path in
                // Top-Left
                path.move(to: CGPoint(x: 0, y: length))
                path.addLine(to: CGPoint(x: 0, y: cornerRadius))
                path.addQuadCurve(to: CGPoint(x: cornerRadius, y: 0), control: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: length, y: 0))

                // Top-Right
                path.move(to: CGPoint(x: geo.size.width - length, y: 0))
                path.addLine(to: CGPoint(x: geo.size.width - cornerRadius, y: 0))
                path.addQuadCurve(to: CGPoint(x: geo.size.width, y: cornerRadius), control: CGPoint(x: geo.size.width, y: 0))
                path.addLine(to: CGPoint(x: geo.size.width, y: length))

                // Bottom-Left
                path.move(to: CGPoint(x: 0, y: geo.size.height - length))
                path.addLine(to: CGPoint(x: 0, y: geo.size.height - cornerRadius))
                path.addQuadCurve(to: CGPoint(x: cornerRadius, y: geo.size.height), control: CGPoint(x: 0, y: geo.size.height))
                path.addLine(to: CGPoint(x: length, y: geo.size.height))

                // Bottom-Right
                path.move(to: CGPoint(x: geo.size.width - length, y: geo.size.height))
                path.addLine(to: CGPoint(x: geo.size.width - cornerRadius, y: geo.size.height))
                path.addQuadCurve(to: CGPoint(x: geo.size.width, y: geo.size.height - cornerRadius), control: CGPoint(x: geo.size.width, y: geo.size.height))
                path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height - length))
            }
            .stroke(CoffeeTheme.accentWarmGold, style: StrokeStyle(lineWidth: thickness, lineCap: .round))
        }
    }

    // MARK: - Action Buttons
    private var controlButtons: some View {
        VStack(spacing: 12) {
            // Camera / Scan Button
            Button {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    showCameraPicker = true
                } else {
                    simulateScanningDemoBag(isStarbucks: true)
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "camera.viewfinder")
                        .font(.headline)
                    Text("Capture Coffee Bag")
                        .font(.headline.weight(.bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(CoffeeTheme.accentPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: CoffeeTheme.accentPrimary.opacity(0.4), radius: 8, y: 4)
            }
            .buttonStyle(.plain)

            // Photos Picker Button
            PhotosPicker(selection: $selectedItem, matching: .images) {
                HStack(spacing: 6) {
                    Image(systemName: "photo.on.rectangle")
                    Text("Choose from Photo Library")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(Color.white.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            // Quick Demo Simulation Buttons for Instant Testing
            VStack(spacing: 8) {
                Text("OR TEST DEMO BAGS IN SIMULATOR")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(Color.white.opacity(0.4))
                    .padding(.top, 4)

                HStack(spacing: 10) {
                    Button {
                        simulateScanningDemoBag(isStarbucks: true)
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "cup.and.saucer.fill")
                            Text("Starbucks Demo")
                        }
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(CoffeeTheme.accentWarmGold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(Color.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    Button {
                        simulateScanningDemoBag(isStarbucks: false)
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "sparkles")
                            Text("Onyx Demo")
                        }
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(CoffeeTheme.accentWarmGold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(Color.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Scanned Result Card
    private var scannedResultCard: some View {
        guard let result = scannedData else { return AnyView(EmptyView()) }

        return AnyView(
            VStack(alignment: .leading, spacing: 14) {
                // Header badge + Retake
                HStack {
                    HStack(spacing: 5) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(CoffeeTheme.accentSuccess)
                        Text("APPLE VISION PARSED")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(1)
                            .foregroundStyle(CoffeeTheme.accentSuccess)
                    }

                    Spacer()

                    Button {
                        withAnimation {
                            scannedData = nil
                            scannedImage = nil
                            didSaveSuccess = false
                            showRawText = false
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Retake")
                        }
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.white.opacity(0.7))
                    }
                }

                // Bag Photo Thumbnail + Editable Title & Roaster
                HStack(alignment: .top, spacing: 12) {
                    if let img = scannedImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 58, height: 58)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.2), lineWidth: 1))
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 58, height: 58)
                            Image(systemName: "cup.and.saucer.fill")
                                .font(.title3)
                                .foregroundStyle(CoffeeTheme.accentWarmGold)
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        TextField("Roaster (e.g. Starbucks, Onyx)", text: $editRoaster)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(CoffeeTheme.accentWarmGold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        TextField("Bean Name (e.g. Pike Place Roast)", text: $editName)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }

                // Origin, Process, and Elevation
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("ORIGIN")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(Color.white.opacity(0.5))
                        TextField("Origin", text: $editOrigin)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .frame(maxWidth: .infinity)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("ROAST")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(Color.white.opacity(0.5))
                        Picker("Roast", selection: $editRoast) {
                            Text("Light").tag(RoastLevel.light)
                            Text("Med").tag(RoastLevel.medium)
                            Text("Med-Dark").tag(RoastLevel.mediumDark)
                            Text("Dark").tag(RoastLevel.dark)
                        }
                        .pickerStyle(.menu)
                        .tint(CoffeeTheme.accentWarmGold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }

                // Flavor Notes Chips
                VStack(alignment: .leading, spacing: 6) {
                    Text("TASTING NOTES")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.5))

                    FlowLayout(spacing: 6) {
                        ForEach(editNotes, id: \.self) { note in
                            Text(note)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(CoffeeTheme.accentWarmGold)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                }

                // Expandable Raw OCR Text Inspection
                if !result.rawTextLines.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                showRawText.toggle()
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: showRawText ? "chevron.down" : "chevron.right")
                                    .font(.caption2.weight(.bold))
                                Text("Vision Extracted Text (\(result.rawTextLines.count) lines)")
                                    .font(.caption2.weight(.semibold))
                                Spacer()
                            }
                            .foregroundStyle(Color.white.opacity(0.6))
                        }
                        .buttonStyle(.plain)

                        if showRawText {
                            VStack(alignment: .leading, spacing: 3) {
                                ForEach(Array(result.rawTextLines.enumerated()), id: \.offset) { idx, line in
                                    Text("\(idx + 1). \(line)")
                                        .font(.system(size: 10, design: .monospaced))
                                        .foregroundStyle(Color.white.opacity(0.8))
                                }
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.black.opacity(0.4))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .padding(.top, 4)
                }

                // Add to Cellar Button
                Button {
                    saveEditedToCellar()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: didSaveSuccess ? "checkmark" : "plus.circle.fill")
                        Text(didSaveSuccess ? "Saved to Bean Cellar!" : "Save to Bean Cellar")
                    }
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(didSaveSuccess ? CoffeeTheme.accentSuccess : CoffeeTheme.accentPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(didSaveSuccess)
            }
            .padding(18)
            .background(Color(red: 0.14, green: 0.12, blue: 0.10))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(CoffeeTheme.accentWarmGold.opacity(0.4), lineWidth: 1)
            )
        )
    }

    // MARK: - Actions
    private func processImage(_ image: UIImage) async {
        isScanning = true
        errorMessage = nil
        scannedImage = image

        do {
            let data = try await CoffeeBagVisionScanner.shared.scanImage(image)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            await MainActor.run {
                withAnimation {
                    populateFields(with: data)
                    scannedData = data
                    isScanning = false
                }
            }
        } catch {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            await MainActor.run {
                errorMessage = error.localizedDescription
                isScanning = false
            }
        }
    }

    private func simulateScanningDemoBag(isStarbucks: Bool) {
        isScanning = true
        errorMessage = nil
        scannedImage = nil

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)

            let demo: ScannedCoffeeBagData
            if isStarbucks {
                demo = ScannedCoffeeBagData(
                    beanName: "Pike Place Roast",
                    roaster: "Starbucks",
                    origin: "Latin America",
                    elevationMeters: 1450,
                    process: "Washed & Natural Blend",
                    roastLevel: .medium,
                    flavorNotes: ["Chocolate", "Toasted Nut", "Smooth Caramel"],
                    roastDate: Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date(),
                    rawTextLines: [
                        "STARBUCKS",
                        "PIKE PLACE ROAST",
                        "WHOLE BEAN 100% ARABICA",
                        "MEDIUM ROAST",
                        "SMOOTH WITH CHOCOLATE & TOASTED NUT NOTES",
                        "LATIN AMERICA"
                    ]
                )
            } else {
                demo = ScannedCoffeeBagData(
                    beanName: "Yirgacheffe Idido G1",
                    roaster: "Onyx Coffee Lab",
                    origin: "Ethiopia",
                    elevationMeters: 2150,
                    process: "Natural Anaerobic",
                    roastLevel: .light,
                    flavorNotes: ["Jasmine", "Bergamot", "Peach"],
                    roastDate: Calendar.current.date(byAdding: .day, value: -8, to: Date()) ?? Date(),
                    rawTextLines: [
                        "ONYX COFFEE LAB",
                        "ETHIOPIA YIRGACHEFFE IDIDO",
                        "GRADE 1 NATURAL ANAEROBIC",
                        "2150 MASL",
                        "JASMINE, BERGAMOT, PEACH",
                        "ROAST DATE OCT 14"
                    ]
                )
            }

            withAnimation {
                populateFields(with: demo)
                scannedData = demo
                isScanning = false
            }
        }
    }

    private func populateFields(with data: ScannedCoffeeBagData) {
        editName = data.beanName
        editRoaster = data.roaster
        editOrigin = data.origin
        editProcess = data.process
        editElevation = data.elevationMeters
        editRoast = data.roastLevel
        editNotes = data.flavorNotes
    }

    private func saveEditedToCellar() {
        let bean = CoffeeBeanEntity(
            name: editName.isEmpty ? "Specialty Coffee" : editName,
            roaster: editRoaster.isEmpty ? "Artisanal Roaster" : editRoaster,
            origin: editOrigin.isEmpty ? "Single Origin" : editOrigin,
            elevationMeters: editElevation,
            processRaw: editProcess.isEmpty ? "Washed" : editProcess,
            roastLevel: editRoast,
            flavorNotes: editNotes,
            roastDate: scannedData?.roastDate ?? Date(),
            remainingGrams: 250.0,
            isFavorite: true
        )

        modelContext.insert(bean)
        try? modelContext.save()

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        withAnimation {
            didSaveSuccess = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            dismiss()
        }
    }

    private func startScanlineAnimation() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            scanlineOffset = 140
        }
    }
}

// MARK: - UIViewControllerRepresentable for Camera Capture
private struct CameraPickerRepresentable: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPickerRepresentable

        init(_ parent: CameraPickerRepresentable) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let img = info[.originalImage] as? UIImage {
                parent.image = img
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    CoffeeBagScannerView()
        .modelContainer(CoffeeModelContainer.shared)
}
