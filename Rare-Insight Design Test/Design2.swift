//import SwiftUI
//import RealityKit
//
//struct ContentView: View {
//    @State private var showImmersiveSpace = false
//    @EnvironmentObject var auraModel: AuraViewModel
//    @Environment(\.openImmersiveSpace) var openImmersiveSpace
//    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
//    
//    var body: some View {
//        VStack(spacing: 30) {
//            Text("Aura Visualization")
//                .font(.largeTitle)
//                .fontWeight(.bold)
//            
//            if !showImmersiveSpace {
//                Text("This requires an immersive space to render 3D content")
//                    .font(.body)
//                    .foregroundStyle(.secondary)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal)
//                
//                Button {
//                    Task {
//                        await openImmersiveSpace(id: "AuraSpace")
//                        showImmersiveSpace = true
//                    }
//                } label: {
//                    Label("Enter Aura View", systemImage: "play.circle.fill")
//                        .font(.title2)
//                }
//                .buttonStyle(.borderedProminent)
//                .controlSize(.large)
//            } else {
//                // Show controls when immersive space is active
//                ControlPanel()
//                
//                Button {
//                    Task {
//                        await dismissImmersiveSpace()
//                        showImmersiveSpace = false
//                    }
//                } label: {
//                    Label("Exit Aura View", systemImage: "xmark.circle.fill")
//                        .font(.title2)
//                }
//                .buttonStyle(.bordered)
//                .controlSize(.large)
//            }
//        }
//        .padding()
//        .frame(width: 500)
//    }
//}
//
//// MARK: - ImmersiveView
//struct ImmersiveView: View {
//    @EnvironmentObject var auraModel: AuraViewModel
//    
//    var body: some View {
//        RealityView { content in
//            print("ImmersiveView RealityView created")
//            
//            // Create head
//            let headEntity = createSimulatedHead()
//            content.add(headEntity)
//            auraModel.headEntity = headEntity
//            print("Added head")
//            
//            // Create aura container
//            let auraContainer = Entity()
//            auraContainer.position = headEntity.position
//            content.add(auraContainer)
//            auraModel.auraEntity = auraContainer
//            print("Added aura container")
//            
//            // Create particles
//            auraModel.createAuraParticles()
//            print("Created particles")
//            
//            // Start updates
//            auraModel.startUpdates()
//            print("Started updates")
//        }
//    }
//    
//    private func createSimulatedHead() -> ModelEntity {
//        let headMesh = MeshResource.generateSphere(radius: 0.15)
//        var headMaterial = SimpleMaterial()
//        headMaterial.color = .init(tint: .init(white: 0.7, alpha: 1.0))
//        let head = ModelEntity(mesh: headMesh, materials: [headMaterial])
//        
//        // Eyes
//        let eyeMesh = MeshResource.generateSphere(radius: 0.02)
//        var eyeMaterial = SimpleMaterial()
//        eyeMaterial.color = .init(tint: .init(white: 0.1, alpha: 1.0))
//        
//        let leftEye = ModelEntity(mesh: eyeMesh, materials: [eyeMaterial])
//        leftEye.position = [-0.04, 0.03, 0.13]
//        head.addChild(leftEye)
//        
//        let rightEye = ModelEntity(mesh: eyeMesh, materials: [eyeMaterial])
//        rightEye.position = [0.04, 0.03, 0.13]
//        head.addChild(rightEye)
//        
//        head.position = [0, 1.6, -1.0]
//        
//        return head
//    }
//}
//
//// MARK: - ViewModel
//class AuraViewModel: ObservableObject {
//    @Published var affectRangeScore: Float = 0.5
//    @Published var affectStabilityScore: Float = 0.5
//    @Published var isRunning: Bool = true
//    
//    var headEntity: ModelEntity?
//    var auraEntity: Entity?
//    var auraCloudEntity: ModelEntity?
//    private var auraParticles: [AuraParticle] = []
//    private var rimParticles: [RimParticle] = []
//    
//    private var animationTimer: Timer?
//    private var animationPhase: Float = 0
//    private var wavePhase: Float = 0  // Global wave phase for rim
//    
//    private let particleCount = 500
//    private let rimParticleCount = 120
//    
//    struct AuraParticle {
//        let entity: ModelEntity
//        let angle: Float
//        let baseRadius: Float
//        let phase: Float
//        let speed: Float
//    }
//    
//    struct RimParticle {
//        let entity: ModelEntity
//        let angle: Float
//        let spatialPhase: Float  // Position along the circle for wave pattern
//    }
//    
//    func startUpdates() {
//        animationPhase = Float.random(in: 0...100)
//        
//        animationTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { [weak self] _ in
//            guard let self = self else { return }
//            if self.isRunning {
//                let speed = 0.1 + (self.affectRangeScore * self.affectRangeScore) * 4.0
//                self.animationPhase += (1.0/60.0) * speed
//                self.updateAura()
//            }
//        }
//    }
//    
//    func getColor(affectStabilityScore: Float) -> UIColor {
//        if affectStabilityScore < 0.3 {
//            return UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
//        } else if affectStabilityScore < 0.6 {
//            return UIColor(red: 0.9, green: 0.9, blue: 0.2, alpha: 1.0)
//        } else {
//            return UIColor(red: 0.05, green: 0.5, blue: 0.2, alpha: 1.0)
//        }
//    }
//    
//    func createAuraParticles() {
//        guard let auraEntity = auraEntity else { return }
//        
//        auraParticles.forEach { $0.entity.removeFromParent() }
//        auraParticles.removeAll()
//        
//        rimParticles.forEach { $0.entity.removeFromParent() }
//        rimParticles.removeAll()
//        
//        // Create background cloud sphere - multiple layers for edge fade
//        let cloudLayers = [
//            (radius: 0.32, opacity: 0.05),
//            (radius: 0.29, opacity: 0.10),
//            (radius: 0.26, opacity: 0.15)
//        ]
//        
//        for layer in cloudLayers {
//            let cloudMesh = MeshResource.generateSphere(radius: Float(layer.radius))
//            
//            var cloudMaterial = PhysicallyBasedMaterial()
//            cloudMaterial.baseColor = .init(tint: getColor(affectStabilityScore: affectStabilityScore))
//            cloudMaterial.opacityThreshold = 0.0
//            cloudMaterial.blending = .transparent(opacity: .init(floatLiteral: Float(layer.opacity)))
//            
//            let cloudEntity = ModelEntity(mesh: cloudMesh, materials: [cloudMaterial])
//            cloudEntity.name = "cloud_\(layer.radius)"
//            auraEntity.addChild(cloudEntity)
//            
//            // Store reference to middle layer for updates
//            if layer.radius == 0.29 {
//                auraCloudEntity = cloudEntity
//            }
//        }
//        
//        // Create rim particles
//        let rimRadius: Float = 0.30
//        for i in 0..<rimParticleCount {
//            let angle = Float(i) / Float(rimParticleCount) * .pi * 2
//            
//            // Slightly larger particles for visibility
//            let particleMesh = MeshResource.generateSphere(radius: 0.004)
//            
//            let material = UnlitMaterial(color: getColor(affectStabilityScore: affectStabilityScore))
//            let particleEntity = ModelEntity(mesh: particleMesh, materials: [material])
//            
//            let x = cos(angle) * rimRadius
//            let y = sin(angle) * rimRadius
//            particleEntity.position = [x, y, 0]
//            
//            let particle = RimParticle(
//                entity: particleEntity,
//                angle: angle,
//                spatialPhase: Float(i) / Float(rimParticleCount) * .pi * 2 * 12  // 12 waves around circle
//            )
//            
//            auraEntity.addChild(particleEntity)
//            rimParticles.append(particle)
//        }
//        
//        // Create inner aura particles
//        for i in 0..<particleCount {
//            let angle = Float(i) / Float(particleCount) * .pi * 2
//            let baseRadius: Float = 0.2 + Float.random(in: 0...0.08)
//            
//            // Tiny particle sphere
//            let particleMesh = MeshResource.generateSphere(radius: 0.002)
//            
//            let material = UnlitMaterial(color: getColor(affectStabilityScore: affectStabilityScore))
//            let particleEntity = ModelEntity(mesh: particleMesh, materials: [material])
//            
//            let x = cos(angle) * baseRadius
//            let y = sin(angle) * baseRadius
//            particleEntity.position = [x, y, 0]
//            
//            let particle = AuraParticle(
//                entity: particleEntity,
//                angle: angle,
//                baseRadius: baseRadius,
//                phase: Float.random(in: 0...(.pi * 2)),
//                speed: 0.5 + Float.random(in: 0...0.5)
//            )
//            
//            auraEntity.addChild(particleEntity)
//            auraParticles.append(particle)
//        }
//    }
//    
//    func updateAura() {
//        guard !auraParticles.isEmpty else { return }
//        
//        let intensity = 0.3 + affectRangeScore * 0.7
//        
//        // Update cloud colors - all layers
//        if let auraEntity = auraEntity {
//            let cloudLayers = [
//                (radius: 0.32, opacity: 0.05),
//                (radius: 0.29, opacity: 0.10),
//                (radius: 0.26, opacity: 0.15)
//            ]
//            
//            for layer in cloudLayers {
//                if let cloudEntity = auraEntity.children.first(where: { $0.name == "cloud_\(layer.radius)" }) as? ModelEntity {
//                    var cloudMaterial = PhysicallyBasedMaterial()
//                    cloudMaterial.baseColor = .init(tint: getColor(affectStabilityScore: affectStabilityScore))
//                    cloudMaterial.opacityThreshold = 0.0
//                    cloudMaterial.blending = .transparent(opacity: .init(floatLiteral: Float(layer.opacity)))
//                    cloudEntity.model?.materials = [cloudMaterial]
//                }
//            }
//        }
//        
//        // Update rim particles with wavering motion
//        let rimBaseRadius: Float = 0.30
//        let waveAmplitude = 0.02 + ((1.0 - affectStabilityScore) * 0.08)  // Amplitude increases with stability
//        let waveVelocity = 0.2 + ((1.0 - affectStabilityScore) * 5.0)  // Much wider speed range: 0.2 to 5.2
//        
//        // Update global wave phase
//        wavePhase += waveVelocity * (1.0/60.0)
//        
//        for particle in rimParticles {
//            // Combine two counter-rotating waves to reduce rotation appearance
//            let wave1 = sin(particle.spatialPhase + wavePhase)
//            let wave2 = sin(-particle.spatialPhase + wavePhase * 0.7)
//            let waveOffset = (wave1 + wave2) * 0.5 * waveAmplitude
//            
//            let currentRadius = rimBaseRadius + waveOffset
//            
//            let x = cos(particle.angle) * currentRadius
//            let y = sin(particle.angle) * currentRadius
//            
//            // Add subtle z-axis movement
//            let z = sin(particle.spatialPhase * 2 + wavePhase * 0.5) * waveAmplitude * 0.3
//            
//            particle.entity.position = [x, y, z]
//            
//            // Update color
//            let color = getColor(affectStabilityScore: affectStabilityScore)
//            let material = UnlitMaterial(color: color)
//            particle.entity.model?.materials = [material]
//        }
//        
//        // Update inner aura particles
//        for particle in auraParticles {
//            let waveOffset = sin(animationPhase + particle.phase) * 0.04
//            let radius = particle.baseRadius + waveOffset
//            
//            let orbitAngle = particle.angle + animationPhase * particle.speed
//            let x = cos(orbitAngle) * radius
//            let y = sin(orbitAngle) * radius
//            let z = sin(animationPhase * 0.7 + particle.phase) * 0.03
//            
//            particle.entity.position = [x, y, z]
//            
//            let pulseAlpha = intensity * (0.6 + sin(animationPhase * 3 + particle.phase) * 0.4)
//            
//            let color = getColor(affectStabilityScore: affectStabilityScore).withAlphaComponent(CGFloat(pulseAlpha))
//            
//            let material = UnlitMaterial(color: color)
//            particle.entity.model?.materials = [material]
//        }
//    }
//    
//    func reset() {
//        affectRangeScore = 0.5
//        affectStabilityScore = 0.5
//        animationPhase = 0
//        wavePhase = 0
//    }
//    
//    deinit {
//        animationTimer?.invalidate()
//    }
//}
//
//// MARK: - Control Panel
//struct ControlPanel: View {
//    @EnvironmentObject var viewModel: AuraViewModel
//    
//    var body: some View {
//        VStack(spacing: 20) {
//            VStack(alignment: .leading, spacing: 10) {
//                HStack {
//                    Text("Affect Range Index")
//                        .font(.subheadline)
//                        .fontWeight(.semibold)
//                    Spacer()
//                    Text(String(format: "%.2f", viewModel.affectRangeScore))
//                        .font(.system(.body, design: .monospaced))
//                        .foregroundStyle(.blue)
//                }
//                
//                Slider(value: $viewModel.affectRangeScore, in: 0...1)
//                    .tint(.blue)
//            }
//            
//            VStack(alignment: .leading, spacing: 10) {
//                HStack {
//                    Text("Affect Stability Index")
//                        .font(.subheadline)
//                        .fontWeight(.semibold)
//                    Spacer()
//                    Text(String(format: "%.2f", viewModel.affectStabilityScore))
//                        .font(.system(.body, design: .monospaced))
//                        .foregroundStyle(.orange)
//                }
//                
//                Slider(value: $viewModel.affectStabilityScore, in: 0...1)
//                    .tint(.orange)
//            }
//            
//            HStack(spacing: 12) {
//                Button {
//                    viewModel.isRunning.toggle()
//                } label: {
//                    Label(
//                        viewModel.isRunning ? "Pause" : "Resume",
//                        systemImage: viewModel.isRunning ? "pause.fill" : "play.fill"
//                    )
//                    .frame(maxWidth: .infinity)
//                }
//                .buttonStyle(.borderedProminent)
//                
//                Button {
//                    viewModel.reset()
//                } label: {
//                    Label("Reset", systemImage: "arrow.counterclockwise")
//                        .frame(maxWidth: .infinity)
//                }
//                .buttonStyle(.bordered)
//            }
//        }
//        .padding()
//    }
//}
//
//#Preview {
//    ContentView()
//        .environmentObject(AuraViewModel())
//}
