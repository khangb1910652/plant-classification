//
//  ResultView.swift
//  LeafClassification
//
//  Created by Nguyễn Duy Khang on 06/11/2023.
//

import SwiftUI
import CoreML
import Vision
import WikipediaKit
import CoreData
import Reachability

struct ResultView: View {
    @Binding var selectedImage: UIImage?
    @State private var predictionText: String = ""
    @State private var confidence: Float = 0.0
    @State private var isWikipediaSheetPresented = false
    @State private var wikipediaDataEn: WikipediaSearchResults?
    @State private var wikipediaDataVi: WikipediaSearchResults?
    @State private var wikipediaImage: UIImage?
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var reachability = Reachability.shared
    @State private var isShowingNoInternetAlert = false
    
    var body: some View {
        if let uiImage = selectedImage {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .aspectRatio(contentMode: .fit)
        }
        Text("Prediction: \(predictionText)")
        Text("Confidence: \(String(format: "%.2f", confidence))")
            .onAppear {
                if let uiImage = selectedImage {
                    classifyImage(uiImage)
                    saveToHistory()
                }
            }
        if(predictionText != "Unknown") {
            Button(action: {
                if reachability.currentPath.isReachable {
                    fetchDataFromWikipedia(element: predictionText)
                } else {
                    isShowingNoInternetAlert = true
                }
                
            }) {
                Text("View Wikipedia Info")
            }
            .buttonStyle(.borderedProminent)
            .sheet(isPresented: $isWikipediaSheetPresented) {
                WikipediaSheet(dataEn: wikipediaDataEn, dataVi: wikipediaDataVi, image: wikipediaImage)
            }
            .alert(isPresented: $isShowingNoInternetAlert) {
                Alert(
                    title: Text("No Internet Connection"),
                    message: Text("Please check your internet connection and try again."),
                    dismissButton: .default(Text("OK"))
                )
            }
            .padding()
        }
    }
    func classifyImage(_ image: UIImage) {
        let confidenceThreshold: Float = 0.5
        if let model = try? VNCoreMLModel(for: plant_model().model) {
            let request = VNCoreMLRequest(model: model) { request, error in
                if let results = request.results as? [VNClassificationObservation] {
                    if let topResult = results.first {
                        self.predictionText = topResult.identifier.split(separator: "_").joined(separator: " ")
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
            }
            if let ciImage = CIImage(image: image) {
                let handler = VNImageRequestHandler(ciImage: ciImage)
                do {
                    try handler.perform([request])
                } catch {
                    self.predictionText = "Error: \(error)"
                }
            }
        }
    }
    func fetchDataFromWikipedia(element: String) {
        Wikipedia.shared.requestSearchResults(method: WikipediaSearchMethod.fullText, language: WikipediaLanguage("en"), term: element) { data, error in
            if let resultData = data {
                self.wikipediaDataEn = resultData
                if let wikiData = resultData.items.first {
                    if let imageURL = wikiData.imageURL {
                        loadImage(url: imageURL)
                    }
                }
            }
        }
        Wikipedia.shared.requestSearchResults(method: WikipediaSearchMethod.fullText, language: WikipediaLanguage("vi"), term: element) { data, error in
            if let resultData = data {
                self.wikipediaDataVi = resultData
            }
        }
        self.isWikipediaSheetPresented = true
    }
    
    func loadImage(url: URL) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.wikipediaImage = image
                    }
                }
            }
        }
    }
    func saveToHistory() {
        let historyItem = HistoryPlant(context: viewContext)
        historyItem.id = UUID()
        historyItem.name = predictionText
        if let uiImage = selectedImage {
            historyItem.imageData = uiImage.pngData()!
        }
        //        savedItem.descriptionText = wikipediaDataEn?.items.first?.displayText ?? ""
        historyItem.date = Date()
        do {
            try viewContext.save()
        } catch {
            print("Error saving to Core Data: \(error)")
        }
    }
    
}
