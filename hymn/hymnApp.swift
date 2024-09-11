//
//  hymnApp.swift
//  hymn
//
//  Created by Tapas Mahanta on 6/18/23.
//

import SwiftUI

@main
struct hymnApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
