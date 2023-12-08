//
//  MyPlantView.swift
//  LeafClassification
//
//  Created by Nguyễn Duy Khang on 08/11/2023.
//

import SwiftUI
import Vision
import WikipediaKit
import CoreData

struct MyPlantView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SavedPlant.nameEn, ascending: false)],
        animation: .default)
    private var plants: FetchedResults<SavedPlant>
    @State private var selectedPlant: SavedPlant?
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
            ForEach(plants.filter { searchText.isEmpty || $0.nameEn?.lowercased().contains(searchText.lowercased()) == true }, id: \.self) { plant in
                VStack(alignment: .leading) {
                    Button(action: {
                        selectedPlant = plant
                    }) {
                        HStack(alignment: .center) {
                            Image(uiImage: UIImage(data: plant.imageData ?? Data()) ?? UIImage(systemName: "photo")!)
                                .resizable()
                                .frame(width: 100, height: 100)
                                .cornerRadius(10)
                            VStack(){
                                Text(plant.nameEn ?? "Unknown")
                                    .font(.system(size: 20))
                                    .multilineTextAlignment(.center)
                                HStack() {
                                    Spacer()
                                    Text("Show more")
                                        .font(.system(size: 14, weight: .light))
                                    Spacer()
                                }
                            }
                            .padding()
                        }
                    }
                    .sheet(item: $selectedPlant) { plant in
                        MyPlantDetailView(nameEn: plant.nameEn, nameVi: plant.nameVi, descriptionEn: plant.descriptionEn, descriptionVi: plant.descriptionVi, image: UIImage(data: plant.imageData ?? Data()))
                    }
                }
                .edgesIgnoringSafeArea(.all)
            }
            .onDelete(perform: deleteUsers)
        }
        .navigationTitle("My Plant List")
    }
    private func deleteUsers(offsets: IndexSet) {
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
}
