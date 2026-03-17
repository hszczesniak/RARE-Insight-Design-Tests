//
//  AffectModel.swift
//  Rare-Insight Design Test
//

import SwiftUI
import Combine

@MainActor
final class AffectModel: ObservableObject {

    // MARK: – Metrics (inertia removed)
    @Published var coherence: Float = 0.75
    @Published var stability: Float = 0.50
    @Published var range:     Float = 0.50

    // MARK: – Interpretation helpers
    func coherenceLabel() -> String {
        switch coherence {
        case 0..<0.3:   return "Incongruent affect"
        case 0.3..<0.7: return "Partial alignment"
        default:        return "Congruent affect"
        }
    }

    func stabilityLabel() -> String {
        switch stability {
        case 0..<0.3:   return "Labile affect"
        case 0.3..<0.7: return "Normal variation"
        default:        return "Rigid affect"
        }
    }

    func rangeLabel() -> String {
        switch range {
        case 0..<0.3:   return "Constricted range"
        case 0.3..<0.7: return "Normal range"
        default:        return "Expansive range"
        }
    }

    func clinicalNote() -> String {
        var notes: [String] = []
        if coherence < 0.3 { notes.append("Marked affect incongruence.") }
        if stability < 0.3 { notes.append("Significant affective lability.") }
        if stability > 0.7 { notes.append("Rigid/restricted affect.") }
        if range < 0.3     { notes.append("Blunted emotional expression.") }
        if range > 0.7     { notes.append("Expansive/dramatized expression.") }
        return notes.isEmpty
            ? "Composite presentation within normal parameters."
            : notes.joined(separator: " ")
    }
}
