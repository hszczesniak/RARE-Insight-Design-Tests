//
//  AffectFieldImmersiveView.swift
//  Rare-Insight Design Test
//

import SwiftUI
import RealityKit

// MARK: – Immersive Space Root
// Wrapped in TimelineView so the update closure fires every frame,
// driving continuous animation even when no slider is moving.

struct AffectFieldImmersiveView: View {
    @EnvironmentObject var model: AffectModel

    var body: some View {
        TimelineView(.animation) { timeline in
            RealityView { content in
                let anchor = AnchorEntity(.head)
                anchor.position = [0, 0, -1.5]
                content.add(anchor)

                let scene = AffectFieldScene()
                anchor.addChild(scene)

            } update: { content in
                guard let anchor = content.entities.first,
                      let scene = anchor.children.first as? AffectFieldScene else { return }
                // timeline.date forces SwiftUI to re-evaluate every animation frame
                let _ = timeline.date
                scene.update(
                    coherence: model.coherence,
                    stability: model.stability,
                    range:     model.range
                )
            }
        }
    }
}

// MARK: – Scene root

@MainActor
final class AffectFieldScene: Entity {

    private let face         = FaceEntity()
    private let rangeField   = RangeFieldEntity()
    private let particles    = ParticleFieldEntity()
    private let coherenceRig = CoherenceOrbsEntity()

    required init() {
        super.init()

        addChild(rangeField)
        addChild(particles)
        addChild(face)
        addChild(coherenceRig)

        rangeField.position   = [0, -0.05, -0.35]   // well behind all other entities
        particles.position    = [0,  0.00, -0.10]   // behind face
        face.position         = [0,  0.00,  0.45]   // well in front of particles
        coherenceRig.position = [0,  0.28,  0.20]   // pushed forward, always in front of range
    }

    func update(coherence: Float, stability: Float, range: Float) {
        rangeField.update(range: range)
        particles.update(stability: stability, range: range)
        coherenceRig.update(coherence: coherence)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: – Mock Face
// ─────────────────────────────────────────────────────────────────────────────
@MainActor
final class FaceEntity: Entity {

    required init() {
        super.init()
        buildFace()
    }

    private func buildFace() {
        let skinColor  = UIColor(red: 0.85, green: 0.72, blue: 0.58, alpha: 1.0)
        let darkBrown  = UIColor(red: 0.15, green: 0.10, blue: 0.05, alpha: 1.0)
        let lipColor   = UIColor(red: 0.75, green: 0.42, blue: 0.35, alpha: 1.0)
        let eyeWhite   = UIColor(red: 0.95, green: 0.93, blue: 0.88, alpha: 1.0)
        let irisColor  = UIColor(red: 0.25, green: 0.45, blue: 0.55, alpha: 1.0)
        let pupilColor = UIColor.black

        func mat(_ color: UIColor) -> UnlitMaterial {
            var m = UnlitMaterial()
            m.color = .init(tint: color)
            return m
        }

        let head = ModelEntity(mesh: .generateSphere(radius: 0.12), materials: [mat(skinColor)])
        head.scale = [0.82, 1.0, 0.78]
        addChild(head)

        let hair = ModelEntity(mesh: .generateSphere(radius: 0.125), materials: [mat(darkBrown)])
        hair.scale = [0.84, 0.62, 0.80]
        hair.position = [0, 0.055, 0]
        addChild(hair)

        let neck = ModelEntity(mesh: .generateCylinder(height: 0.08, radius: 0.038), materials: [mat(skinColor)])
        neck.position = [0, -0.155, 0]
        addChild(neck)

        let shoulders = ModelEntity(mesh: .generateSphere(radius: 0.18),
                                    materials: [mat(UIColor(red: 0.18, green: 0.18, blue: 0.28, alpha: 1))])
        shoulders.scale = [1.0, 0.30, 0.55]
        shoulders.position = [0, -0.26, 0]
        addChild(shoulders)

        for sx: Float in [-1, 1] {
            let ex: Float = sx * 0.038
            let ey: Float = 0.018
            let ez: Float = 0.096

            let white = ModelEntity(mesh: .generateSphere(radius: 0.018), materials: [mat(eyeWhite)])
            white.scale = [1.0, 0.62, 0.55]
            white.position = [ex, ey, ez]
            addChild(white)

            let iris = ModelEntity(mesh: .generateSphere(radius: 0.011), materials: [mat(irisColor)])
            iris.scale = [1.0, 1.0, 0.55]
            iris.position = [ex, ey, ez + 0.004]
            addChild(iris)

            let pupil = ModelEntity(mesh: .generateSphere(radius: 0.006), materials: [mat(pupilColor)])
            pupil.scale = [1.0, 1.0, 0.55]
            pupil.position = [ex, ey, ez + 0.007]
            addChild(pupil)

            let brow = ModelEntity(
                mesh: .generateBox(size: [0.034, 0.005, 0.004], cornerRadius: 0.002),
                materials: [mat(darkBrown)]
            )
            brow.position = [ex, ey + 0.026, ez - 0.005]
            addChild(brow)
        }

        let nose = ModelEntity(
            mesh: .generateBox(size: [0.018, 0.022, 0.018], cornerRadius: 0.007),
            materials: [mat(UIColor(red: 0.78, green: 0.62, blue: 0.48, alpha: 1))]
        )
        nose.position = [0, -0.010, 0.108]
        addChild(nose)

        let upperLip = ModelEntity(
            mesh: .generateBox(size: [0.052, 0.010, 0.010], cornerRadius: 0.004),
            materials: [mat(lipColor)]
        )
        upperLip.position = [0, -0.050, 0.102]
        addChild(upperLip)

        let lowerLip = ModelEntity(
            mesh: .generateBox(size: [0.050, 0.013, 0.010], cornerRadius: 0.005),
            materials: [mat(lipColor)]
        )
        lowerLip.position = [0, -0.063, 0.100]
        addChild(lowerLip)

        for sx: Float in [-1, 1] {
            let ear = ModelEntity(mesh: .generateSphere(radius: 0.018), materials: [mat(skinColor)])
            ear.scale = [0.45, 0.70, 0.45]
            ear.position = [sx * 0.118, 0.005, 0]
            addChild(ear)
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: – Layer 1 · RANGE — Expanding sphere glow
// ─────────────────────────────────────────────────────────────────────────────
@MainActor
final class RangeFieldEntity: Entity {

    private var glowSpheres: [ModelEntity] = []
    private let layerCount = 6
    private var phase: Float = 0

    required init() {
        super.init()
        for i in 0..<layerCount {
            let sphere = ModelEntity(
                mesh: .generateSphere(radius: 1.0),
                materials: [makeGlowMaterial(layer: i)]
            )
            sphere.components[OpacityComponent.self] = OpacityComponent(opacity: 0)
            addChild(sphere)
            glowSpheres.append(sphere)
        }
    }

    func update(range: Float) {
        currentRange = range   // no phase increment — no pulse, no flashing

        // Fixed radius based purely on range value — constant, no animation
        let r = lerp(0.15, 0.30, range)

        for (i, sphere) in glowSpheres.enumerated() {
            sphere.scale = SIMD3(repeating: r * (1.0 + Float(i) * 0.22))

            // Brighter alphas, constant (no sine-based flicker)
            let baseAlpha: Float
            if range < 0.3 {
                baseAlpha = 0.18
            } else if range > 0.7 {
                baseAlpha = lerp(0.35, 0.55, (range - 0.7) / 0.3) * (1.0 - Float(i) * 0.10)
            } else {
                baseAlpha = lerp(0.18, 0.35, (range - 0.3) / 0.4) * (1.0 - Float(i) * 0.12)
            }
            sphere.components[OpacityComponent.self] = OpacityComponent(opacity: baseAlpha)
        }

        // Outer ring — bright constant edge
        glowSpheres.last?.components[OpacityComponent.self] =
            OpacityComponent(opacity: min(range * 0.75, 0.75))

        // Refresh tint colour every frame so it tracks range changes
        for (i, sphere) in glowSpheres.enumerated() {
            sphere.model?.materials = [makeGlowMaterial(layer: i)]
        }
    }

    // range value stored so makeGlowMaterial can tint by current range
    private var currentRange: Float = 0.5

    private func makeGlowMaterial(layer: Int) -> UnlitMaterial {
        // Low range → cool gray. High range → warm yellow.
        // Interpolate RGB: gray(0.55,0.55,0.58) → yellow(0.95,0.88,0.20)
        let t = CGFloat(max(0, min(1, currentRange)))
        let layerDim = CGFloat(1.0 - Float(layer) * 0.06)
        let r = lerp(0.55, 0.95, t) * layerDim
        let g = lerp(0.55, 0.88, t) * layerDim
        let b = lerp(0.58, 0.20, t) * layerDim
        var mat = UnlitMaterial()
        mat.color = .init(tint: UIColor(red: r, green: g, blue: b, alpha: 1.0))
        mat.blending = .transparent(opacity: .init(floatLiteral: 0.6))
        mat.faceCulling = .back
        return mat
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: – Layer 2 · STABILITY — Particle field
// ─────────────────────────────────────────────────────────────────────────────
@MainActor
final class ParticleFieldEntity: Entity {

    struct Particle {
        var angle: Float
        var radius: Float
        var speed: Float
        var verticalScale: Float
        var yOffset: Float
        var hueVariance: Float
        var size: Float
        var phaseOffset: Float
        var entity: ModelEntity
    }

    private var particlePool: [Particle] = []
    private let count = 270
    private var t: Float = 0

    required init() {
        super.init()
        buildParticles()
    }

    private func buildParticles() {
        for _ in 0..<count {
            let mesh = MeshResource.generateSphere(radius: 0.006)
            var mat = UnlitMaterial()
            mat.color = .init(tint: .white)
            mat.blending = .transparent(opacity: .init(floatLiteral: 0.6))
            let e = ModelEntity(mesh: mesh, materials: [mat])
            addChild(e)
            particlePool.append(Particle(
                angle:         Float.random(in: 0...(2 * .pi)),
                radius:        Float.random(in: 0.20...0.55),
                speed:         Float.random(in: 0.018...0.065),
                verticalScale: Float.random(in: 0.80...1.20),
                yOffset:       Float.random(in: -0.35...0.35),
                hueVariance:   Float.random(in: -0.05...0.05),
                size:          Float.random(in: 0.005...0.012),
                phaseOffset:   Float.random(in: 0...(2 * .pi)),
                entity:        e
            ))
        }
    }

    func update(stability: Float, range: Float) {
        t += 0.016

        for i in 0..<particlePool.count {
            var p = particlePool[i]

            let angSpeed: Float
            if stability < 0.3 {
                // labile — very fast and chaotic
                angSpeed = p.speed * lerp(28, 14, stability / 0.3)
            } else if stability > 0.95 {
                // only the very top (0.95–1.0) truly slows down
                angSpeed = p.speed * lerp(6.0, 4.0, (stability - 0.95) / 0.05)
            } else {
                // 0.3–0.95: always visibly moving, faster when less stable
                // at stability=0.5 → lerp(8, 14, 0.5) = 11× base — clearly visible
                // at stability=0.9 → lerp(8, 14, ~0.1) = ~8.6× base — still moving
                angSpeed = p.speed * lerp(8.0, 14.0, 1 - stability)
            }
            p.angle += angSpeed * 0.016

            let radVariance: Float = stability > 0.7 ? 0 :
                stability < 0.3 ? sin(t * 4 + p.phaseOffset) * 0.10 * (1 - stability) :
                0.015 * (1 - stability)

            var noiseX: Float = 0, noiseY: Float = 0
            if stability < 0.3 {
                let chaos = (0.3 - stability) / 0.3
                noiseX = sin(t * (3 + Float(i) * 0.09) + p.phaseOffset) * chaos * 0.12
                noiseY = cos(t * (2.4 + Float(i) * 0.07) + p.phaseOffset * 1.3) * chaos * 0.10
            }

            let baseRadius = p.radius   // fixed orbit, not scaled by range
            let r = max(0.08, baseRadius + radVariance)

            p.entity.position = SIMD3(
                cos(p.angle) * r + noiseX,
                p.yOffset + noiseY,
                sin(p.angle) * r * p.verticalScale
            )
            p.entity.scale = SIMD3(repeating: p.size / 0.006)

            // Palette: red (labile <0.3) → yellow (mid 0.3–0.6) → green (stable >0.6)
            // matches: UIColor(0.8,0.2,0.2) → UIColor(0.9,0.9,0.2) → UIColor(0.05,0.5,0.2)
            // with per-particle hue variance for a natural look
            let particleColor: UIColor
            let vr = CGFloat(p.hueVariance * 0.15)   // small variance on each channel
            if stability < 0.3 {
                // red zone — lerp red→yellow as stability rises toward 0.3
                let blend = CGFloat(stability / 0.3)
                particleColor = UIColor(
                    red:   lerp(0.80, 0.90, blend) + vr,
                    green: lerp(0.18, 0.88, blend) + vr,
                    blue:  lerp(0.18, 0.18, blend) + vr,
                    alpha: 1.0
                )
            } else if stability < 0.6 {
                // yellow zone — lerp yellow→green as stability rises toward 0.6
                let blend = CGFloat((stability - 0.3) / 0.3)
                particleColor = UIColor(
                    red:   lerp(0.90, 0.20, blend) + vr,
                    green: lerp(0.88, 0.60, blend) + vr,
                    blue:  lerp(0.18, 0.22, blend) + vr,
                    alpha: 1.0
                )
            } else {
                // green zone — stays green, slight brightness variance
                particleColor = UIColor(
                    red:   0.08 + vr,
                    green: lerp(0.55, 0.65, CGFloat(p.hueVariance + 0.5)) + vr,
                    blue:  0.22 + vr,
                    alpha: 1.0
                )
            }

            let alpha: Float
            if stability > 0.7 {
                alpha = 0.85
            } else if stability < 0.3 {
                let flicker = abs(sin(t * 5 + p.phaseOffset))
                alpha = lerp(0.75, 1.0, (0.3 - stability) / 0.3 * flicker)
            } else {
                alpha = 0.80
            }

            var mat = UnlitMaterial()
            mat.color = .init(tint: particleColor.withAlphaComponent(CGFloat(alpha)))
            mat.blending = .transparent(opacity: .init(floatLiteral: alpha))
            p.entity.model?.materials = [mat]

            particlePool[i] = p
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: – Layer 3 · COHERENCE — Dual orbs above head
// ─────────────────────────────────────────────────────────────────────────────
// Uses SimpleMaterial with a custom mesh — two separate sphere entities with
// sorting handled by giving each a different renderingOrder so the right orb
// always renders on top of the left without clipping either.
@MainActor
final class CoherenceOrbsEntity: Entity {

    private let physOrb  = ModelEntity()
    private let behavOrb = ModelEntity()
    private let blendOrb = ModelEntity()
    private var t: Float = 0
    private let orbRadius: Float = 0.09

    required init() {
        super.init()

        let mesh = MeshResource.generateSphere(radius: orbRadius)
        let blendMesh = MeshResource.generateSphere(radius: orbRadius * 0.75)

        physOrb.model  = .init(mesh: mesh,      materials: [makeOrbMaterial(hue: 0.60, alpha: 0.92)])
        behavOrb.model = .init(mesh: mesh,      materials: [makeOrbMaterial(hue: 0.75, alpha: 0.88)])
        blendOrb.model = .init(mesh: blendMesh, materials: [makeOrbMaterial(hue: 0.62, alpha: 0.0)])

        // Give each orb a distinct render order so they never z-fight
        physOrb.components.set(ModelSortGroupComponent(group: ModelSortGroup(depthPass: nil), order: 0))
        behavOrb.components.set(ModelSortGroupComponent(group: ModelSortGroup(depthPass: nil), order: 1))
        blendOrb.components.set(ModelSortGroupComponent(group: ModelSortGroup(depthPass: nil), order: 2))

        addChild(physOrb)
        addChild(behavOrb)
        addChild(blendOrb)
    }

    func update(coherence: Float) {
        t += 0.016

        let maxSep: Float = orbRadius * 2.5
        let sep = lerp(0, maxSep, 1 - coherence)

        physOrb.position  = [-sep, 0, 0]
        behavOrb.position = [ sep, 0, 0]
        blendOrb.position = [   0, 0, 0]

        let behavHue = lerp(0.76, 0.60, coherence)
        let flicker: Float = coherence < 0.3 ? (0.3 - coherence) / 0.3 : 0
        let fv = flicker * (sin(t * 18) * 0.5 + 0.5)

        let physAlpha  = max(0.55, 0.92 - fv * 0.20)
        let behavAlpha = max(0.55, 0.88 - fv * 0.25)

        if coherence < 0.3 {
            let jitter = flicker * 0.015
            physOrb.position.x  += Float.random(in: -jitter...jitter)
            physOrb.position.y  += Float.random(in: -jitter...jitter)
            behavOrb.position.x += Float.random(in: -jitter...jitter)
            behavOrb.position.y += Float.random(in: -jitter...jitter)
        }

        physOrb.model?.materials  = [makeOrbMaterial(hue: 0.60,    alpha: physAlpha)]
        behavOrb.model?.materials = [makeOrbMaterial(hue: behavHue, alpha: behavAlpha)]

        let blendAlpha: Float = coherence > 0.55 ? (coherence - 0.55) / 0.45 * 0.50 : 0
        blendOrb.model?.materials = [makeOrbMaterial(hue: 0.62, alpha: blendAlpha)]
        blendOrb.isEnabled = coherence > 0.55
    }

    private func makeOrbMaterial(hue: Float, alpha: Float) -> UnlitMaterial {
        var mat = UnlitMaterial()
        let a = max(0, min(1, alpha))
        mat.color = .init(tint: UIColor(
            hue:        CGFloat(hue),
            saturation: 0.88,
            brightness: 1.00,
            alpha:      CGFloat(a)
        ))
        mat.blending = .transparent(opacity: .init(floatLiteral: a))
        mat.faceCulling = .none
        return mat
    }
}

// MARK: – Helpers
private func lerp(_ a: Float, _ b: Float, _ t: Float) -> Float {
    a + (b - a) * t
}

private func lerp(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat {
    a + (b - a) * t
}
