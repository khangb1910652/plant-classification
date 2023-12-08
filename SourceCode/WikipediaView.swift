//
//  WikipediaView.swift
//  LeafClassification
//
//  Created by Nguyễn Duy Khang on 08/11/2023.
//

import SwiftUI
import Vision
import WikipediaKit
import CoreData

struct WikipediaSheet: View {
    let dataEn: WikipediaSearchResults?
    let dataVi: WikipediaSearchResults?
    let image: UIImage?
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var selectedLanguage = 0
    
    var body: some View {
        ScrollView {
            VStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .aspectRatio(contentMode: .fit)
                        .padding(.top, 16)
                        .padding()
                }
                
                if let dataEn = dataEn {
                    Picker(selection: $selectedLanguage, label: Text("Language")) {
                        Text("English").tag(0)
                        Text("Vietnamese").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    if selectedLanguage == 0 {
                        Text(dataEn.items.first?.title ?? "")
                            .font(.title)
                            .padding()
                        
                        ScrollView {
                            Text(dataEn.items.first?.displayText ?? "")
                                .padding()
                        }
                    } else if let dataVi = dataVi {
                        Text(dataVi.items.first?.title ?? "")
                            .font(.title)
                            .padding()
                        
                        ScrollView {
                            Text(dataVi.items.first?.displayText ?? "")
                                .padding()
                        }
                    }
                }
            }
            .onChange(of: image) {
                if !checkIfNameExists(dataEn!.items.first?.title ?? "") {
                    saveToMyPlant()
                }
            }
        }
    }
    func checkIfNameExists(_ name: String) -> Bool {
        let fetchRequest: NSFetchRequest<SavedPlant> = SavedPlant.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "nameEn == %@", name)
        
        do {
            let matchingItems = try viewContext.fetch(fetchRequest)
            return !matchingItems.isEmpty
        } catch {
            print("Error checking if name exists: \(error)")
            return false
        }
    }
    func saveToMyPlant() {
        let savedItem = SavedPlant(context: viewContext)
        savedItem.id = UUID()
        savedItem.nameEn = dataEn?.items.first?.title ?? ""
        savedItem.nameVi = dataVi?.items.first?.title ?? ""
        if let uiImage = image {
            savedItem.imageData = uiImage.pngData()!
        }
        savedItem.descriptionEn = dataEn?.items.first?.displayText ?? ""
        savedItem.descriptionVi = dataVi?.items.first?.displayText ?? ""
        savedItem.date = Date()
        do {
            try viewContext.save()
        } catch {
            print("Error saving to Core Data: \(error)")
        }
    }
}

