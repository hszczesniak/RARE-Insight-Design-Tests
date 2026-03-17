//
//  ContentView.swift
//  Rare-Insight Design Test
//

import SwiftUI

struct ContentView: View {
    @State private var showImmersiveSpace = false
    @EnvironmentObject var model: AffectModel
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                Text("Affect Field Monitor")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                // ── Open / Close AR button ──
                Button {
                    Task {
                        if showImmersiveSpace {
                            await dismissImmersiveSpace()
                            showImmersiveSpace = false
                        } else {
                            await openImmersiveSpace(id: "AffectField")
                            showImmersiveSpace = true
                        }
                    }
                } label: {
                    Label(
                        showImmersiveSpace ? "Exit AR Overlay" : "Enter AR Overlay",
                        systemImage: showImmersiveSpace ? "xmark.circle.fill" : "play.circle.fill"
                    )
                    .font(.title2)
                }
                .buttonStyle(.borderedProminent)
                .tint(showImmersiveSpace ? .red.opacity(0.8) : .blue.opacity(0.8))
                .controlSize(.large)

                Divider()

                // ── Metric sliders ──
                MetricRow(title: "Coherence", value: $model.coherence,
                          label: model.coherenceLabel(), color: .blue,
                          lowLabel: "Incongruent", highLabel: "Congruent")

                MetricRow(title: "Stability", value: $model.stability,
                          label: model.stabilityLabel(), color: .cyan,
                          lowLabel: "Labile", highLabel: "Rigid")

                MetricRow(title: "Range", value: $model.range,
                          label: model.rangeLabel(), color: .orange,
                          lowLabel: "Constricted", highLabel: "Expansive")

                Divider()

                // ── Clinical note ──
                VStack(alignment: .leading, spacing: 6) {
                    Text("CLINICAL NOTE")
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(.secondary)
                    Text(model.clinicalNote())
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(24)
        }
        .frame(width: 500)
    }
}

// MARK: – Reusable metric row
struct MetricRow: View {
    let title: String
    @Binding var value: Float
    let label: String
    let color: Color
    let lowLabel: String
    let highLabel: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.headline)
                Spacer()
                Text(String(format: "%.2f", value))
                    .font(.system(.title3, design: .monospaced, weight: .bold))
                    .foregroundStyle(color)
            }

            Slider(value: $value, in: 0...1)
                .tint(color)

            HStack {
                Text(lowLabel)
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.tertiary)
                Spacer()
                Text(highLabel)
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.tertiary)
            }

            Text(label)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)
                .padding(.leading, 8)
                .overlay(alignment: .leading) {
                    Rectangle()
                        .fill(color.opacity(0.5))
                        .frame(width: 2)
                }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
    }
}
