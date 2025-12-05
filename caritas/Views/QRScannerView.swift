//
//  QRScannerView.swift
//  caritas
//
//  Vista para escanear códigos QR usando AVFoundation (compatible iOS 16+).
//

import SwiftUI
import AVFoundation
import AudioToolbox
import Combine

struct QRScannerView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = QRScannerViewModel()

    var body: some View {
        ZStack {
            // Cámara usando AVFoundation
            QRCameraView(viewModel: viewModel)
                .ignoresSafeArea()

            VStack {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Text("Escanear QR")
                        .font(.gotham(.bold, style: .headline))
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "xmark")
                        .font(.title2.bold())
                        .foregroundColor(.clear)
                }
                .padding()
                .background(Color.azulMarino.opacity(0.9))

                Spacer()

                // Overlay con indicador
                VStack(spacing: 20) {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.aqua, lineWidth: 3)
                        .frame(width: 250, height: 250)

                    Text("Acerca el QR a la cámara")
                        .font(.gotham(.regular, style: .body))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()

                Spacer()

                if viewModel.isLoading {
                    VStack(spacing: 12) {
                        ProgressView()
                            .tint(.aqua)
                        Text("Buscando donación...")
                            .font(.gotham(.regular, style: .body))
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black.opacity(0.7))
                }

                // Mensaje de error
                if let error = viewModel.errorMessage {
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.red)
                        Text(error)
                            .font(.gotham(.regular, style: .body))
                            .foregroundColor(.white)
                            .lineLimit(2)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.8))
                }
            }

        }
        .sheet(item: $viewModel.foundDonation) { donation in
            NavigationStack {
                DonationDetailView(donation: donation)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                viewModel.foundDonation = nil
                            }) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.azulMarino)
                            }
                        }
                    }
            }
            .presentationDetents([.large, .medium])
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            viewModel.requestCameraPermission()
        }
        .onDisappear {
            viewModel.cleanup()
        }
    }
}

// MARK: - Camera View

struct QRCameraView: UIViewControllerRepresentable {
    let viewModel: QRScannerViewModel

    func makeUIViewController(context: Context) -> QRScannerController {
        let controller = QRScannerController(viewModel: viewModel)
        return controller
    }

    func updateUIViewController(_ uiViewController: QRScannerController, context: Context) {}
}

// MARK: - Scanner Controller

class QRScannerController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    weak var viewModel: QRScannerViewModel?
    
    private var lastDetectedCode: String?
    private var lastDetectionTime: Date?
    private var isSetup = false

    init(viewModel: QRScannerViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("✅ QRScannerController.viewDidLoad")
        setupCamera()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("✅ QRScannerController.viewDidAppear")
        if !isSetup {
            startScanning()
            isSetup = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("⏹️ QRScannerController.viewWillDisappear")
        // Stop scanning deterministically before the controller begins deallocation.
        stopScanning()
        // Break delegate callback path to avoid late calls.
        if let outputs = captureSession?.outputs {
            for output in outputs {
                if let metadata = output as? AVCaptureMetadataOutput {
                    metadata.setMetadataObjectsDelegate(nil, queue: nil)
                }
            }
        }
    }

    private func setupCamera() {
        print("🎬 Setting up camera...")
        
        let session = AVCaptureSession()
        captureSession = session

        // Input de video
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("❌ No video device found")
            return
        }

        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
                print("✅ Video input added")
            }
        } catch {
            print("❌ Error adding video input: \(error)")
            return
        }

        // Output de metadata
        let metadataOutput = AVCaptureMetadataOutput()
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
            print("✅ Metadata output added")
        }

        // Preview layer
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        self.previewLayer = previewLayer
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer)
        print("✅ Preview layer added")
    }

    // Make start/stop synchronous on main to avoid races during dismissal.
    func startScanning() {
        print("▶️ Starting QR scanning...")
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.captureSession?.startRunning()
            print("✅ Capture session started")
        }
    }

    func stopScanning() {
        guard captureSession?.isRunning == true else { return }
        print("⏹️ Stopping QR scanning...")
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.captureSession?.stopRunning()
            print("✅ Capture session stopped")
        }
    }

    func resetScanning() {
        print("🔄 Resetting scanning...")
        lastDetectedCode = nil
        lastDetectionTime = nil
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
    }

    // MARK: - AVCaptureMetadataOutputObjectsDelegate

    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        print("📲 metadataOutput: \(metadataObjects.count) objects")

        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              metadataObject.type == .qr,
              let stringValue = metadataObject.stringValue else {
            return
        }

        print("✅ QR detected: \(stringValue)")

        // Antidebounce
        let now = Date()
        if lastDetectedCode == stringValue,
           let lastTime = lastDetectionTime,
           now.timeIntervalSince(lastTime) < 1.0 {
            print("⏱️ Debounced - same code")
            return
        }

        lastDetectedCode = stringValue
        lastDetectionTime = now

        // Vibración
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

        // Notificar al ViewModel
        print("📞 Calling viewModel.handleQRDetected")
        viewModel?.handleQRDetected(stringValue)
    }
}

// MARK: - ViewModel

@MainActor
class QRScannerViewModel: NSObject, ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var foundDonation: Donation?

    private let firestoreService = FirestoreService.shared

    func requestCameraPermission() {
        print("🔐 Requesting camera permission...")
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    print("✅ Camera permission granted")
                } else {
                    print("❌ Camera permission denied")
                    self?.errorMessage = "Se requiere permiso de cámara"
                }
            }
        }
    }

    func handleQRDetected(_ qrContent: String) {
        print("🔍 handleQRDetected: \(qrContent)")
        isLoading = true
        errorMessage = nil

        Task {
            do {
                print("🔎 Fetching donation: \(qrContent)")
                if let donation = try await firestoreService.fetchDonation(by: qrContent) {
                    print("✅ Donation found!")
                    self.foundDonation = donation
                } else {
                    print("❌ Donation not found")
                    self.errorMessage = "Donación no encontrada"
                }
            } catch {
                print("⚠️ Error: \(error.localizedDescription)")
                self.errorMessage = "Error: \(error.localizedDescription)"
            }
            self.isLoading = false
        }
    }

    func cleanup() {
        print("🧹 Cleaning up...")
        // No back-reference to controller anymore; nothing to stop here.
    }
}

// MARK: - Preview

#Preview {
    QRScannerView()
}
