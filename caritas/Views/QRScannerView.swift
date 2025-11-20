//
//  QRScannerView.swift
//  caritas
//
//  Vista para escanear códigos QR de donaciones.
//

import SwiftUI
@preconcurrency import AVFoundation
import Combine

struct QRScannerView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = QRScannerViewModel()

    var body: some View {
        ZStack {
            // Cámara de fondo
            QRScannerCameraView(
                session: viewModel.captureSession,
                onQRDetected: { qrContent in
                    viewModel.handleQRDetected(qrContent)
                }
            )
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
                    // Placeholder para alineación
                    Image(systemName: "xmark")
                        .font(.title2.bold())
                        .foregroundColor(.clear)
                }
                .padding()
                .background(Color.azulMarino.opacity(0.9))

                Spacer()

                // Indicador/Overlay
                VStack(spacing: 20) {
                    // Marco de escaneo
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.aqua, lineWidth: 3)
                        .frame(width: 250, height: 250)

                    Text("Acerca el QR a la cámara")
                        .font(.gotham(.regular, style: .body))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.4))

                Spacer()

                // Footer con información de carga
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

            // Sheet para mostrar donación encontrada
            if let donation = viewModel.foundDonation {
                NavigationStack {
                    DonationDetailView(donation: donation)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: {
                                    viewModel.foundDonation = nil
                                    viewModel.startScanning()
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
        }
        .onAppear {
            viewModel.requestCameraPermission()
            viewModel.startScanning()
        }
        .onDisappear {
            viewModel.stopScanning()
        }
    }
}

// MARK: - Camera View Controller

struct QRScannerCameraView: UIViewControllerRepresentable {
    let session: AVCaptureSession
    let onQRDetected: (String) -> Void

    func makeUIViewController(context: Context) -> QRScannerViewController {
        let controller = QRScannerViewController()
        controller.captureSession = session
        controller.onQRDetected = onQRDetected
        return controller
    }

    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {}
}

// MARK: - QR Scanner View Controller

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var onQRDetected: ((String) -> Void)?
    private var lastDetectedCode: String?
    private var lastDetectionTime: Date?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let session = captureSession else { return }

        // Configurar preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer!)

        // Configurar metadata output
        let metadataOutput = AVCaptureMetadataOutput()
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        }

        // No iniciar la sesión aquí; el ViewModel controla start/stop en su propia cola.
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              metadataObject.type == .qr,
              let stringValue = metadataObject.stringValue else { return }

        // Evitar detectar el mismo código varias veces en corto tiempo
        let now = Date()
        if lastDetectedCode == stringValue,
           let lastTime = lastDetectionTime,
           now.timeIntervalSince(lastTime) < 1.0 {
            return
        }

        lastDetectedCode = stringValue
        lastDetectionTime = now

        // Vibrar para feedback
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

        // Parar la sesión para evitar múltiples detecciones en segundo plano
        if let session = captureSession, session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                session.stopRunning()
            }
        }

        // Llamar el callback
        onQRDetected?(stringValue)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
    }
}

// MARK: - View Model

@MainActor
class QRScannerViewModel: NSObject, ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var foundDonation: Donation?

    let captureSession = AVCaptureSession()
    private let firestoreService = FirestoreService.shared

    override init() {
        super.init()
        setupCaptureSession()
    }

    private func setupCaptureSession() {
        // All interactions with captureSession happen on the main actor
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            }
        } catch {
            print("Error setting up video input: \(error)")
        }
    }

    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if !granted {
                DispatchQueue.main.async {
                    self.errorMessage = "Se requiere permiso de cámara para escanear QR."
                }
            }
        }
    }

    func handleQRDetected(_ qrContent: String) {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                // El contenido del QR es el ID de la donación
                if let donation = try await firestoreService.fetchDonation(by: qrContent) {
                    self.foundDonation = donation
                } else {
                    self.errorMessage = "Donación no encontrada."
                    startScanning()
                }
            } catch {
                self.errorMessage = "Error al buscar donación: \(error.localizedDescription)"
                startScanning()
            }
            self.isLoading = false
        }
    }

    func startScanning() {
        // Ensure on main actor
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }

    func stopScanning() {
        // Ensure on main actor
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
}

// MARK: - Preview

#Preview {
    QRScannerView()
}
