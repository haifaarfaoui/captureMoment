import SwiftUI
import AVFoundation

struct CameraView: View {
    @StateObject private var cameraViewModel = CameraViewModel()
    
    @State private var photoCount: Int = 5 // Default number of photos
    @State private var timeInterval: Double = 3.0 // Default time delay in seconds
    
    var body: some View {
        ZStack {
            VStack {
                ZStack {
                    if cameraViewModel.isCameraRunning {
                        CameraPreview(session: cameraViewModel.session)
                            .onAppear {
                                cameraViewModel.startSession()
                            }
                            .onDisappear {
                                cameraViewModel.stopSession()
                            }
                    } else {
                        Color.black
                    }
                }
                .aspectRatio(3/4, contentMode: .fill)
                .ignoresSafeArea()
                .background(Color.black)
                
                // Photo Count Input
                Stepper(value: $photoCount, in: 1...20, step: 1) {
                    Text("Number of Photos: \(photoCount)")
                }
                .padding()
                
                // Time Interval Input
                HStack {
                    Text("Time Interval: \(String(format: "%.1f", timeInterval)) seconds")
                    Slider(value: $timeInterval, in: 0.5...10, step: 0.5)
                }
                .padding()
                
                Button(action: {
                    cameraViewModel.startCapturingPhotos(photoCount: photoCount, timeInterval: timeInterval)
                }) {
                    Text("Capture \(photoCount) Photos")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                }
                
                // Display Captured Photos
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(cameraViewModel.capturedImages, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipped()
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.frame
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

#Preview {
    CameraView()
}
