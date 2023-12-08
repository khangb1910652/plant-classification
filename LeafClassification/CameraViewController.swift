//
//  CameraViewController.swift
//  LeafClassification
//
//  Created by Nguyễn Duy Khang on 06/11/2023.
//

import Foundation
import UIKit
import AVFoundation
import Vision

final class CameraViewController: UIViewController {
    weak var delegate: CameraViewControllerDelegate?
    
    private var captureSession: AVCaptureSession?
    private var videoOutput: AVCaptureVideoDataOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    private var predictionText: String = ""
    private var confidence: Float = 0.0
    
    private var isProcessing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        
        guard let captureSession = captureSession else { return }
        
        guard let backCamera = AVCaptureDevice.default(for: .video) else {
            print("Unable to access back camera")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            videoOutput = AVCaptureVideoDataOutput()
            
            if captureSession.canAddInput(input) && captureSession.canAddOutput(videoOutput!) {
                captureSession.addInput(input)
                captureSession.addOutput(videoOutput!)
                captureSession.sessionPreset = .hd4K3840x2160
                
                let queue = DispatchQueue(label: "videoQueue")
                videoOutput?.setSampleBufferDelegate(self, queue: queue)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer?.videoGravity = .resizeAspectFill
                previewLayer?.frame = view.bounds
                view.layer.addSublayer(previewLayer!)
                
                captureSession.startRunning()
            }
        } catch {
            print("Error setting up camera: \(error.localizedDescription)")
        }
        let predictLabel = UILabel(frame: CGRect(x: 20, y: 20, width: 300, height: 50))
        predictLabel.textColor = .white
        predictLabel.text = "Prediction: \(predictionText)"
        view.addSubview(predictLabel)
        
        let confidenceLabel = UILabel(frame: CGRect(x: 20, y: 70, width: 300, height: 50))
        confidenceLabel.textColor = .white
        confidenceLabel.text = "Confidence: \(String(format: "%.2f", confidence))"
        view.addSubview(confidenceLabel)
    }
    
    func predictOnFrame(_ frame: UIImage) {
        let confidenceThreshold: Float = 0.5
        if !isProcessing, let model = try? VNCoreMLModel(for: plant_model().model) {
            isProcessing = true
            let request = VNCoreMLRequest(model: model) { request, error in
                if let results = request.results as? [VNClassificationObservation] {
                    if let topResult = results.first {
                        self.predictionText = topResult.identifier
                        self.confidence = topResult.confidence
                        if topResult.confidence < confidenceThreshold {
                            self.predictionText = "Unknown"
                        }
                    } else {
                        self.predictionText = "No prediction available"
                    }
                } else if let error = error {
                    self.predictionText = "Error: \(error)"
                }
                self.isProcessing = false
            }
            
            if let ciImage = CIImage(image: frame) {
                let handler = VNImageRequestHandler(ciImage: ciImage)
                do {
                    try handler.perform([request])
                } catch {
                    self.predictionText = "Error: \(error)"
                }
            }
            
            // Cập nhật UI với kết quả dự đoán
            DispatchQueue.main.async {
                for view in self.view.subviews {
                    if let label = view as? UILabel {
                        if label.text?.contains("Prediction:") ?? false {
                            label.text = "Prediction: \(self.predictionText)"
                        }
                        if label.text?.contains("Confidence:") ?? false {
                            label.text = "Confidence: \(String(format: "%.2f", self.confidence))"
                        }
                    }
                }
            }
        }
    }
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let ciImage = CIImage(cvImageBuffer: pixelBuffer)
        let context = CIContext()
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            let image = UIImage(cgImage: cgImage)
            predictOnFrame(image)
        }
    }
}
