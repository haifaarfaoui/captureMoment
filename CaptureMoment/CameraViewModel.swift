import SwiftUI
import AVFoundation

class CameraViewModel: NSObject, ObservableObject {
    var session: AVCaptureSession
    private var photoOutput: AVCapturePhotoOutput
    private var captureDevice: AVCaptureDevice?
    
    @Published var capturedImages: [UIImage] = []
    @Published var isCameraRunning = false
    
    override init() {
        self.session = AVCaptureSession()
        self.photoOutput = AVCapturePhotoOutput()
        super.init()
        
        setupSession()
    }
    
    func setupSession() {
        session.beginConfiguration()
        
        // Add video input
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            self.captureDevice = device
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                }
            } catch {
                print("Error setting up camera input: \(error)")
            }
        }
        
        // Add photo output
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
        
        session.commitConfiguration()
    }
    
    func startSession() {
        if !session.isRunning {
            session.startRunning()
            isCameraRunning = true
        }
    }
    
    func stopSession() {
        if session.isRunning {
            session.stopRunning()
            isCameraRunning = false
        }
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    // Modified to accept custom delay and photo count
    func startCapturingPhotos(photoCount: Int, timeInterval: Double) {
        capturedImages = []
        startSession()
        
        for i in 0..<photoCount {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * timeInterval) {
                self.capturePhoto()
            }
        }
    }
}

extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("Error capturing photo: \(String(describing: error))")
            return
        }
        
        DispatchQueue.main.async {
            self.capturedImages.append(image)
        }
    }
}

