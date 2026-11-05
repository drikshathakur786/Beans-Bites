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
    @State private var selectedItem: PhotosPickerItem?
    @State private var showCameraPicker = false
    @State private var cameraImage: UIImage?
    @State private var errorMessage: String?
    @State private var didSaveSuccess = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 24) {
                    // Top guidance
                    VStack(spacing: 6) {
                        Text("Scan Coffee Bag")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)

                        Text("Position the label, roaster, and origin inside the frame")
                            .font(.caption)
                            .foregroundStyle(Color.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .padding(.top, 16)

                    // Reticle Camera Viewfinder
                    viewfinderBox
                        .frame(maxWidth: 320, maxHeight: 320)
                        .padding(.vertical, 8)

                    // Results or Action Controls
                    if let result = scannedData {
                        scannedResultCard(result)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else {
                        controlButtons
                    }

                    Spacer()
                }
                .padding(.horizontal, 20)
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
            .photosPicker(isPresented: .constant(false), selection: $selectedItem, matching: .images)
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
                    simulateScanningDemoBag()
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

            // Photos Picker & Demo Simulation Buttons
            HStack(spacing: 10) {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    HStack(spacing: 6) {
                        Image(systemName: "photo.on.rectangle")
                        Text("Photo Album")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(Color.white.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }

                Button {
                    simulateScanningDemoBag()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                        Text("Demo Bag")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(CoffeeTheme.accentWarmGold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(Color.white.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Scanned Result Card
    private func scannedResultCard(_ result: ScannedCoffeeBagData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(CoffeeTheme.accentWarmGold)
                    Text("VISION DETECTED")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(CoffeeTheme.accentWarmGold)
                }

                Spacer()

                Button {
                    withAnimation {
                        scannedData = nil
                        didSaveSuccess = false
                    }
                } label: {
                    Text("Retake")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.white.opacity(0.7))
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(result.roaster.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(Color.white.opacity(0.6))

                Text(result.beanName)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)

                Text("\(result.origin) • \(result.process) • \(result.elevationMeters)m")
                    .font(.caption)
                    .foregroundStyle(Color.white.opacity(0.8))
            }

            // Flavor Notes
            HStack(spacing: 6) {
                ForEach(result.flavorNotes.prefix(3), id: \.self) { note in
                    Text(note)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(CoffeeTheme.accentWarmGold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Capsule())
                }
                Spacer()
            }

            // Add to Cellar Button
            Button {
                saveToCellar(result)
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: didSaveSuccess ? "checkmark" : "plus.circle.fill")
                    Text(didSaveSuccess ? "Saved to Bean Cellar!" : "Add Bag to Cellar")
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
    }

    // MARK: - Actions
    private func processImage(_ image: UIImage) async {
        isScanning = true
        errorMessage = nil

        do {
            let data = try await CoffeeBagVisionScanner.shared.scanImage(image)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            withAnimation {
                scannedData = data
                isScanning = false
            }
        } catch {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            errorMessage = error.localizedDescription
            isScanning = false
        }
    }

    private func simulateScanningDemoBag() {
        isScanning = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)

            withAnimation {
                scannedData = ScannedCoffeeBagData(
                    beanName: "Yirgacheffe Idido G1",
                    roaster: "Onyx Coffee Lab",
                    origin: "Ethiopia",
                    elevationMeters: 2150,
                    process: "Natural Anaerobic",
                    roastLevel: .light,
                    flavorNotes: ["Jasmine", "Bergamot", "Peach"],
                    roastDate: Calendar.current.date(byAdding: .day, value: -8, to: Date()) ?? Date(),
                    rawTextLines: ["Onyx Coffee Lab", "Ethiopia Yirgacheffe Idido G1", "Natural Anaerobic", "2150 masl", "Roasted on Oct 14"]
                )
                isScanning = false
            }
        }
    }

    private func saveToCellar(_ data: ScannedCoffeeBagData) {
        let bean = CoffeeBeanEntity(
            name: data.beanName,
            roaster: data.roaster,
            origin: data.origin,
            elevationMeters: data.elevationMeters,
            processRaw: data.process,
            roastLevel: data.roastLevel,
            flavorNotes: data.flavorNotes,
            roastDate: data.roastDate,
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
