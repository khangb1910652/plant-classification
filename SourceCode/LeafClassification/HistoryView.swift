//
//  HistoryView.swift
//  LeafClassification
//
//  Created by Nguyễn Duy Khang on 07/11/2023.
//

import SwiftUI
import Vision
import WikipediaKit
import CoreData
import Reachability

struct HistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \HistoryPlant.date, ascending: false)],
        animation: .default)
    private var plants: FetchedResults<HistoryPlant>
    @ObservedObject var reachability = Reachability.shared
    @State private var isShowingNoInternetAlert = false
    @State private var isWikipediaSheetPresented = false
    @State private var wikipediaDataEn: WikipediaSearchResults?
    @State private var wikipediaDataVi: WikipediaSearchResults?
    @State private var wikipediaImage: UIImage?
    @State private var searchText = ""
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search", text: $searchText)
        }
        .padding(4)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.gray, lineWidth: 1)
        )
        .padding()
        List {
            ForEach(plants.filter { searchText.isEmpty || $0.name?.lowercased().contains(searchText.lowercased()) == true }, id: \.self) { plant in
                VStack(alignment: .leading) {
                    Button(action: {
                        if plant.name == "Unknown" {
                            isWikipediaSheetPresented = false
                            isShowingNoInternetAlert = false
                        }
                        else if reachability.currentPath.isReachable {
                            fetchDataFromWikipedia(element: plant.name ?? "Unknown")
                            isWikipediaSheetPresented = true
                        } else {
                            isShowingNoInternetAlert = true
                        }
                    }) {
                        HStack(alignment: .center) {
                            Image(uiImage: UIImage(data: plant.imageData ?? Data()) ?? UIImage(systemName: "photo")!)
                                .resizable()
                                .frame(width: 100, height: 100)
                                .cornerRadius(10)
                            VStack(){
                                Text(plant.name ?? "Unknown")
                                    .font(.system(size: 20))
                                    .multilineTextAlignment(.center)
                                HStack() {
                                    Spacer()
                                    if plant.name != "Unknown" {
                                        Text("Show more")
                                            .font(.system(size: 14, weight: .light))
                                    }
                                    Spacer()
                                }
                            }
                            .padding()
                        }
                    }
                }
                .edgesIgnoringSafeArea(.all)
            }
            .onDelete(perform: deleteItem)
        }
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
        .navigationTitle("History List")
    }
    private func deleteItem(offsets: IndexSet) {
        withAnimation {
            offsets.map { plants[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
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
}

