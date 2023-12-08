//
//  LeafClassificationApp.swift
//  LeafClassification
//
//  Created by Nguyễn Duy Khang on 14/10/2023.
//

//import SwiftUI
//import UIKit
//import AVFoundation
//import PhotosUI
//
//struct ContentView: View {
//    @State private var showingOptions = false
//    @State private var selection = "None"
//    @State private var isCameraPickerPresented = false
//    @State private var isImagePickerPresented = false
//    @State private var isCameraViewPresented = false
//    @State private var selectedImage: UIImage?
//    @State private var predictionText: String = ""
//    @State private var confidence: Float = 0.0
//    @State private var selectedItem: PhotosPickerItem? = nil
//    @State private var isResultViewPresented = false
//    @State private var isHistoryViewPresented = false
//    @State private var isMyPlantViewPresented = false
//    @State private var selectedImageData: Data? = nil
//    @Environment(\.managedObjectContext) private var viewContext
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \SavedPlant.date, ascending: false)],
//        animation: .default)
//    private var plants: FetchedResults<SavedPlant>
//
//    var body: some View {
//        NavigationView {
//            ZStack {
//                Image("background")
//                    .resizable()
//                    .scaledToFill()
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .edgesIgnoringSafeArea(.all)
//                VStack {
//                    Spacer()
//                    TabView {
//                        //                        Image("plant_tab_2")
//                        //                            .resizable()
//                        //                            .scaledToFill()
//                        //                        Image("plant_tab_1")
//                        //                            .resizable()
//                        //                            .scaledToFill()
//                        ForEach(plants, id: \.self) { plant in
//                            ZStack() {
//                                Image(uiImage: UIImage(data: plant.imageData ?? Data()) ?? UIImage(systemName: "photo")!)
//                                    .resizable()
//                                    .scaledToFill()
//                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                                VStack() {
//                                    Spacer()
//                                    Text(plant.nameEn ?? "Unknown")
//                                        .font(.system(size: 30, weight: .bold, design: .serif))
//                                        .foregroundColor(Color.white)
//                                        .multilineTextAlignment(.center)
//                                    Text(plant.descriptionEn ?? "No description available")
//                                        .font(.system(size: 16))
//                                        .foregroundColor(Color.white)
//                                        .padding()
//                                        .padding(.bottom, 20)
//                                        .frame(maxWidth: 350, maxHeight: 120)
//                                        .multilineTextAlignment(.center)
//                                }
//                                .frame(maxWidth: 350, maxHeight: 400)
//                            }
//                        }
//                    }
//                    .frame(width: 350, height: 400)
//                    .tabViewStyle(PageTabViewStyle())
//                    .background(Color.white)
//                    .cornerRadius(10)
//                    Spacer()
//
//                    Button(action: {showingOptions = true}) {
//                        HStack {
//                            Image(systemName: "photo.on.rectangle.angled")
//                                .foregroundColor(Color.green)
//                                .font(.system(size: 24))
//                            Text("Classify Plant")
//                                .foregroundColor(.green)
//                                .font(.system(size: 24, weight: .bold))
//                        }
//
//                    }
//                    .frame(width: 350, height: 80)
//                    .background(Color.white)
//                    .cornerRadius(10)
//                    .confirmationDialog("", isPresented: $showingOptions, titleVisibility: .hidden) {
//                        Button("Select a photo") {
//                            isImagePickerPresented = true
//                        }
//                        Button("Take a photo") {
//                            isCameraPickerPresented = true
//                        }
//                        Button("Live preview") {
//                            isCameraViewPresented = true
//                        }
//                    }
//                    .photosPicker(isPresented: $isImagePickerPresented, selection: $selectedItem)
//                    .onChange(of: selectedItem) { newItem in
//                        Task {
//                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
//                                selectedImageData = data
//                                selectedImage = UIImage(data: selectedImageData!)
//                                selectedItem = nil
//                                isResultViewPresented = true
//                            }
//                        }
//                    }
//                    .fullScreenCover(isPresented: $isCameraPickerPresented) {
//                        CameraPicker(selectedImage: $selectedImage)
//                            .edgesIgnoringSafeArea(.all)
//                    }
//                    .onChange(of: selectedImage) {
//                        isResultViewPresented = true
//                    }
//                    .sheet(isPresented: $isCameraViewPresented) {
//                        CameraView(selectedImage: $selectedImage, predictionText: $predictionText, confidence: $confidence)
//                    }
//                    NavigationLink("", destination: ResultView(selectedImage: $selectedImage), isActive: $isResultViewPresented)
//                    NavigationLink("", destination: HistoryView(), isActive: $isHistoryViewPresented)
//                    NavigationLink("", destination: MyPlantView(), isActive: $isMyPlantViewPresented)
//                    HStack {
//                        Button(action: {isMyPlantViewPresented = true}) {
//                            VStack {
//                                Image(systemName: "book")
//                                    .foregroundColor(Color.green)
//                                    .font(.system(size: 24))
//                                Text("View My Plant")
//                                    .foregroundColor(.green)
//                                    .font(.system(size: 24, weight: .bold))
//                            }
//
//                        }
//                        .frame(width: 170, height: 80)
//                        .background(Color.white)
//                        .cornerRadius(10)
//                        Button(action: {isHistoryViewPresented = true}) {
//                            VStack {
//                                Image(systemName: "leaf")
//                                    .foregroundColor(Color.green)
//                                    .font(.system(size: 24))
//                                Text("View History")
//                                    .foregroundColor(.green)
//                                    .font(.system(size: 24, weight: .bold))
//                            }
//                        }
//                        .frame(width: 170, height: 80)
//                        .background(Color.white)
//                        .cornerRadius(10)
//
//                    }
//                    Spacer()
//                }
//            }
//        }
//    }
//}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

import SwiftUI
import UIKit
import AVFoundation
import PhotosUI

struct ContentView: View {
    @State private var showingOptions = false
    @State private var selection = "None"
    @State private var isCameraPickerPresented = false
    @State private var isImagePickerPresented = false
    @State private var isCameraViewPresented = false
    @State private var selectedImage: UIImage?
    @State private var predictionText: String = ""
    @State private var confidence: Float = 0.0
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var isResultViewPresented = false
    @State private var isHistoryViewPresented = false
    @State private var isMyPlantViewPresented = false
    @State private var selectedImageData: Data? = nil
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SavedPlant.date, ascending: false)],
        animation: .default)
    private var plants: FetchedResults<SavedPlant>
    
    var body: some View {
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            NavigationView {
                VStack {
                    Button(action: {showingOptions = true}) {
                        HStack {
                            Image(systemName: "photo.on.rectangle.angled")
                                .foregroundColor(Color.green)
                                .font(.system(size: 24))
                            Text("Classify Plant")
                                .foregroundColor(.green)
                                .font(.system(size: 24, weight: .bold))
                        }
                        
                    }
                    .frame(width: 350, height: 80)
                    .background(isResultViewPresented ? Color.gray : Color.white)
                    .cornerRadius(10)
                    
                    Button(action: {isMyPlantViewPresented = true}) {
                        HStack {
                            Image(systemName: "book")
                                .foregroundColor(Color.green)
                                .font(.system(size: 24))
                            Text("View My Plant")
                                .foregroundColor(.green)
                                .font(.system(size: 24, weight: .bold))
                        }
                        
                    }
                    .frame(width: 350, height: 80)
                    .background(isMyPlantViewPresented ? Color.gray : Color.white)
                    .cornerRadius(10)
                    Button(action: {isHistoryViewPresented = true}) {
                        HStack {
                            Image(systemName: "leaf")
                                .foregroundColor(Color.green)
                                .font(.system(size: 24))
                            Text("View History")
                                .foregroundColor(.green)
                                .font(.system(size: 24, weight: .bold))
                        }
                    }
                    .frame(width: 350, height: 80)
                    .background(isHistoryViewPresented ? Color.gray : Color.white)
                    .accentColor(isHistoryViewPresented ? .white : .green)
                    .cornerRadius(10)
                    Spacer()
                        .confirmationDialog("", isPresented: $showingOptions, titleVisibility: .hidden) {
                            Button("Select a photo") {
                                isImagePickerPresented = true
                            }
                            Button("Take a photo") {
                                isCameraPickerPresented = true
                            }
                            Button("Live preview") {
                                isCameraViewPresented = true
                            }
                        }
                        .photosPicker(isPresented: $isImagePickerPresented, selection: $selectedItem)
                        .onChange(of: selectedItem) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    selectedImageData = data
                                    selectedImage = UIImage(data: selectedImageData!)
                                    selectedItem = nil
                                    isResultViewPresented = true
                                }
                            }
                        }
                        .fullScreenCover(isPresented: $isCameraPickerPresented) {
                            CameraPicker(selectedImage: $selectedImage)
                                .edgesIgnoringSafeArea(.all)
                        }
                        .onChange(of: selectedImage) {
                            isResultViewPresented = true
                        }
                        .sheet(isPresented: $isCameraViewPresented) {
                            CameraView(selectedImage: $selectedImage, predictionText: $predictionText, confidence: $confidence)
                        }
                        NavigationLink("", destination: ResultView(selectedImage: $selectedImage), isActive: $isResultViewPresented)
                        NavigationLink("", destination: HistoryView(), isActive: $isHistoryViewPresented)
                        NavigationLink("", destination: MyPlantView(), isActive: $isMyPlantViewPresented)
                }
                VStack {
                    Text("PLANT CLASSIFICATION")
                        .foregroundColor(.green)
                        .font(.system(size: 30, weight: .bold))
                    Spacer()
                    TabView {
                        //                        Image("plant_tab_2")
                        //                            .resizable()
                        //                            .scaledToFill()
                        //                        Image("plant_tab_1")
                        //                            .resizable()
                        //                            .scaledToFill()
                        ForEach(plants, id: \.self) { plant in
                            ZStack() {
                                Image(uiImage: UIImage(data: plant.imageData ?? Data()) ?? UIImage(systemName: "photo")!)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                VStack() {
                                    Spacer()
                                    Text(plant.nameEn ?? "Unknown")
                                        .font(.system(size: 30, weight: .bold, design: .serif))
                                        .foregroundColor(Color.white)
                                        .multilineTextAlignment(.center)
                                    Text(plant.descriptionEn ?? "No description available")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color.white)
                                        .padding()
                                        .padding(.bottom, 20)
                                        .frame(maxWidth: 350, maxHeight: 120)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: 350, maxHeight: 400)
                            }
                        }
                    }
                    .frame(width: .infinity, height: .infinity)
                    .tabViewStyle(PageTabViewStyle())
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding()
                    Spacer()
                }
            }
            
        } else {
            NavigationView {
                ZStack {
                    Image("background")
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .edgesIgnoringSafeArea(.all)
                    VStack {
                        Spacer()
                        TabView {
                            //                        Image("plant_tab_2")
                            //                            .resizable()
                            //                            .scaledToFill()
                            //                        Image("plant_tab_1")
                            //                            .resizable()
                            //                            .scaledToFill()
                            ForEach(plants, id: \.self) { plant in
                                ZStack() {
                                    Image(uiImage: UIImage(data: plant.imageData ?? Data()) ?? UIImage(systemName: "photo")!)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    VStack() {
                                        Spacer()
                                        Text(plant.nameEn ?? "Unknown")
                                            .font(.system(size: 30, weight: .bold, design: .serif))
                                            .foregroundColor(Color.white)
                                            .multilineTextAlignment(.center)
                                        Text(plant.descriptionEn ?? "No description available")
                                            .font(.system(size: 16))
                                            .foregroundColor(Color.white)
                                            .padding()
                                            .padding(.bottom, 20)
                                            .frame(maxWidth: 350, maxHeight: 120)
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(maxWidth: 350, maxHeight: 400)
                                }
                            }
                        }
                        .frame(width: 350, height: 400)
                        .tabViewStyle(PageTabViewStyle())
                        .background(Color.white)
                        .cornerRadius(10)
                        Spacer()
                        
                        Button(action: {showingOptions = true}) {
                            HStack {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .foregroundColor(Color.green)
                                    .font(.system(size: 24))
                                Text("Classify Plant")
                                    .foregroundColor(.green)
                                    .font(.system(size: 24, weight: .bold))
                            }
                            
                        }
                        .frame(width: 350, height: 80)
                        .background(Color.white)
                        .cornerRadius(10)
                        .confirmationDialog("", isPresented: $showingOptions, titleVisibility: .hidden) {
                            Button("Select a photo") {
                                isImagePickerPresented = true
                            }
                            Button("Take a photo") {
                                isCameraPickerPresented = true
                            }
                            Button("Live preview") {
                                isCameraViewPresented = true
                            }
                        }
                        .photosPicker(isPresented: $isImagePickerPresented, selection: $selectedItem)
                        .onChange(of: selectedItem) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    selectedImageData = data
                                    selectedImage = UIImage(data: selectedImageData!)
                                    selectedItem = nil
                                    isResultViewPresented = true
                                }
                            }
                        }
                        .fullScreenCover(isPresented: $isCameraPickerPresented) {
                            CameraPicker(selectedImage: $selectedImage)
                                .edgesIgnoringSafeArea(.all)
                        }
                        .onChange(of: selectedImage) {
                            isResultViewPresented = true
                        }
                        .sheet(isPresented: $isCameraViewPresented) {
                            CameraView(selectedImage: $selectedImage, predictionText: $predictionText, confidence: $confidence)
                        }
                        NavigationLink("", destination: ResultView(selectedImage: $selectedImage), isActive: $isResultViewPresented)
                        NavigationLink("", destination: HistoryView(), isActive: $isHistoryViewPresented)
                        NavigationLink("", destination: MyPlantView(), isActive: $isMyPlantViewPresented)
                        HStack {
                            Button(action: {isMyPlantViewPresented = true}) {
                                VStack {
                                    Image(systemName: "book")
                                        .foregroundColor(Color.green)
                                        .font(.system(size: 24))
                                    Text("View My Plant")
                                        .foregroundColor(.green)
                                        .font(.system(size: 24, weight: .bold))
                                }
                                
                            }
                            .frame(width: 170, height: 80)
                            .background(Color.white)
                            .cornerRadius(10)
                            Button(action: {isHistoryViewPresented = true}) {
                                VStack {
                                    Image(systemName: "leaf")
                                        .foregroundColor(Color.green)
                                        .font(.system(size: 24))
                                    Text("View History")
                                        .foregroundColor(.green)
                                        .font(.system(size: 24, weight: .bold))
                                }
                            }
                            .frame(width: 170, height: 80)
                            .background(Color.white)
                            .cornerRadius(10)
                            
                        }
                        Spacer()
                    }
                }
            }
        }
    }
}
