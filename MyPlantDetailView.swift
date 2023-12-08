//
//  MyPlantDetailView.swift
//  LeafClassification
//
//  Created by Nguyễn Duy Khang on 08/11/2023.
//

import SwiftUI
import Vision
import WikipediaKit

struct MyPlantDetailView: View {
    let nameEn: String?
    let nameVi: String?
    let descriptionEn: String?
    let descriptionVi: String?
    let image: UIImage?
    
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
                
                if let nameEn = nameEn, let descriptionEn = descriptionEn {
                    Picker(selection: $selectedLanguage, label: Text("Language")) {
                        Text("English").tag(0)
                        Text("Vietnamese").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    if selectedLanguage == 0 {
                        Text(nameEn)
                            .font(.title)
                            .padding()
                        
                        ScrollView {
                            Text(descriptionEn)
                                .padding()
                        }
                    } else if let nameVi = nameVi, let descriptionVi = descriptionVi {
                        Text(nameVi)
                            .font(.title)
                            .padding()
                        
                        ScrollView {
                            Text(descriptionVi)
                                .padding()
                        }
                    }
                }
            }
        }
    }
}
