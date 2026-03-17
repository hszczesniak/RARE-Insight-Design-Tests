//
//  Rare_Insight_Design_TestApp.swift
//  Rare-Insight Design Test
//

import SwiftUI

@main
struct PatientOverlayApp: App {
    @StateObject private var model = AffectModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
        }

        ImmersiveSpace(id: "AffectField") {
            AffectFieldImmersiveView()
                .environmentObject(model)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
