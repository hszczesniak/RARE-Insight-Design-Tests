//
//  Rare_Insight_Design_TestApp.swift
//  Rare-Insight Design Test
//
//  Created by Heather Szczesniak on 10/29/25.
//

import SwiftUI

//@main
//struct PatientOverlayApp: App {
//    var body: some Scene {
//        WindowGroup {
//            Design()
//        }
//    }
//}

// MARK: - App Entry Point
@main
struct PatientOverlayApp: App {
    @StateObject private var auraModel = AuraViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(auraModel)
        }
        
        ImmersiveSpace(id: "AuraSpace") {
            ImmersiveView()
                .environmentObject(auraModel)
        }
    }
}
