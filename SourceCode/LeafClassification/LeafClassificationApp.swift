//
//  LeafClassificationApp.swift
//  LeafClassification
//
//  Created by Nguyễn Duy Khang on 14/10/2023.
//

import SwiftUI

@main
struct LeafClassificationApp: App {
    let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
