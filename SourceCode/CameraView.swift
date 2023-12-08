//
//  CameraView.swift
//  LeafClassification
//
//  Created by Nguyễn Duy Khang on 07/11/2023.
//

import Foundation
import SwiftUI
import UIKit

struct CameraView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var predictionText: String
    @Binding var confidence: Float
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<CameraView>) -> CameraViewController {
        let cameraViewController = CameraViewController()
        cameraViewController.delegate = context.coordinator
        return cameraViewController
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: UIViewControllerRepresentableContext<CameraView>) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, CameraViewControllerDelegate {
        var parent: CameraView
        
        init(parent: CameraView) {
            self.parent = parent
        }
        
        func didCaptureImage(image: UIImage) {
            parent.selectedImage = image
            parent.predictionText = ""
            parent.confidence = 0.0
        }
    }
    
}

protocol CameraViewControllerDelegate: AnyObject {
    func didCaptureImage(image: UIImage)
}
