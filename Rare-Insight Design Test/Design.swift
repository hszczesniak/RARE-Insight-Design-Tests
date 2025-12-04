import SwiftUI

struct Design: View {
    @State private var ovalPosition = CGPoint(x: 790, y: 120)
    @State private var heartPosition = CGPoint(x: 800, y: 350)
    @State private var lability: Double = 0.3
    @State private var heartRate: Double = 75
    @State private var heartScale: Double = 1.0
    @State private var isDraggingOval = false
    @State private var isDraggingHeart = false
    @State private var heartBeatPhase: Double = 0
    @State private var showHeartRateGraph = false
    @State private var showLabilityGraph = false
    @State private var showHeartRateBox = false
    @State private var showLabilityBox = false
    
    // Historical data for graphs (store last 500 readings - 25 seconds)
    @State private var heartRateHistory: [Double] = []
    @State private var labilityHistory: [Double] = []
    
    let dataTimer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // Patient image
            Image("patient")
                .resizable()
                .scaledToFit()
            
            // Wavy oval overlay (head position) - driven by lability
            WavyOvalShape(lability: lability)
                .stroke(labilityColor(lability: lability), lineWidth: 8)
                .frame(width: 130, height: 60)
                .position(ovalPosition)
                .contentShape(Circle())
                .onTapGesture {
                    withAnimation {
                        showLabilityBox.toggle()
                        if !showLabilityBox {
                            showLabilityGraph = false
                        }
                    }
                }
            
            // Pulsing heart overlay (chest position) - driven by heart rate
            Image(systemName: "heart.fill")
                .resizable()
                .foregroundColor(heartRateColor(hr: heartRate))
                .frame(width: 60, height: 60)
                .scaleEffect(heartScale)
                .position(heartPosition)
                .onTapGesture {
                    withAnimation {
                        showHeartRateBox.toggle()
                        if !showHeartRateBox {
                            showHeartRateGraph = false
                        }
                    }
                }
            
            // Line from heart to heart rate box
            if showHeartRateBox {
                Path { path in
                    path.move(to: heartPosition)
                    path.addLine(to: CGPoint(x: 1050, y: 350))
                }
                .stroke(heartRateColor(hr: heartRate), lineWidth: 2)
            }
            
            // Line from oval to lability box
            if showLabilityBox {
                Path { path in
                    path.move(to: ovalPosition)
                    path.addLine(to: CGPoint(x: 1050, y: 120))
                }
                .stroke(labilityColor(lability: lability), lineWidth: 2)
            }
            
            // Heart Rate Box
            if showHeartRateBox {
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Heart Rate")
                                .font(.headline)
                                .foregroundColor(.black.opacity(0.7))
                            Text("\(Int(heartRate)) bpm")
                                .font(.title2)
                                .bold()
                                .foregroundColor(heartRateColor(hr: heartRate))
                        }
                        Spacer()
                        Button(action: {
                            withAnimation {
                                showHeartRateGraph.toggle()
                            }
                        }) {
                            Image(systemName: showHeartRateGraph ? "chevron.up" : "chevron.down")
                                .foregroundColor(.black.opacity(0.4))
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.5))
                    .foregroundColor(.white)
                    
                    if showHeartRateGraph {
                        HeartRateGraphView(data: heartRateHistory)
                            .frame(height: 150)
                            .background(Color.white.opacity(0.3))
                    }
                }
                .frame(width: 200)
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(heartRateColor(hr: heartRate).opacity(0.5), lineWidth: 2)
                )
                .position(x: 1150, y: 350)
                .transition(.opacity)
            }
            
            // Lability Box
            if showLabilityBox {
                VStack(spacing: 0) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Lability")
                                .font(.headline)
                                .foregroundColor(.black.opacity(0.7))
                            Text(String(format: "%.2f", lability))
                                .font(.title2)
                                .bold()
                                .foregroundColor(labilityColor(lability: lability))
                        }
                        Spacer()
                        Button(action: {
                            withAnimation {
                                showLabilityGraph.toggle()
                            }
                        }) {
                            Image(systemName: showLabilityGraph ? "chevron.up" : "chevron.down")
                                .foregroundColor(.black.opacity(0.4))
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.5))
                    .foregroundColor(.white)
                    
                    if showLabilityGraph {
                        LabilityGraphView(data: labilityHistory)
                            .frame(height: 150)
                            .background(Color.white.opacity(0.3))
                    }
                }
                .frame(width: 200)
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(labilityColor(lability: lability).opacity(0.5), lineWidth: 2)
                )
                .position(x: 1150, y: 120)
                .transition(.opacity)
            }
        }
        .onReceive(dataTimer) { _ in
            // Generate mock randomized data with small incremental changes
            // Heart rate changes by ±0 to 5 bpm per update
            let hrChange = Double.random(in: -5...5)
            heartRate = max(40, min(220, heartRate + hrChange))
            
            // Lability changes by ±0 to 0.05 per update
            let labilityChange = Double.random(in: -0.01...0.05)
            lability = max(0, min(1.0, lability + labilityChange))
            
            // Store history (keep last 500 readings - 25 seconds of data)
            heartRateHistory.append(heartRate)
            if heartRateHistory.count > 500 {
                heartRateHistory.removeFirst()
            }
            
            labilityHistory.append(lability)
            if labilityHistory.count > 500 {
                labilityHistory.removeFirst()
            }
            
            // Update heart pulse animation based on heart rate
            // Convert BPM to beats per second, then to phase increment
            let beatsPerSecond = heartRate / 60.0
            let phaseIncrement = beatsPerSecond * 0.05 * 2 * .pi
            heartBeatPhase += phaseIncrement
            
            // Heart scale pulsing
            heartScale = 1.0 + 0.2 * sin(heartBeatPhase)
        }
    }
    
    // Heart rate color coding
    func heartRateColor(hr: Double) -> Color {
        if hr < 60 {
            return Color(red: 0, green: 0, blue: 0.6)  // Bradycardia
        } else if hr >= 60 && hr <= 90 {
            return Color(red: 0, green: 0.4, blue: 0)  // Normal
        } else if hr > 90 && hr <= 110 {
            return Color(red: 0.65, green: 0.45, blue: 0)  // Elevated
        } else {
            return Color(red: 0.6, green: 0, blue: 0)  // High
        }
    }
    
    func labilityColor(lability: Double) -> Color {
        if lability < 0.4 {
            return Color(red: 0, green: 0.4, blue: 0)  // Dark green
        } else if lability < 0.8 {
            return Color(red: 0.65, green: 0.45, blue: 0)  // Golden yellow
        } else {
            return Color(red: 0.6, green: 0, blue: 0)  // Dark red
        }
    }
}

struct HeartRateGraphView: View {
    let data: [Double]
    
    var body: some View {
        GeometryReader { geometry in
            if data.count > 1 {
                ZStack {
                    // Draw colored segments
                    ForEach(0..<data.count-1, id: \.self) { index in
                        Path { path in
                            let width = geometry.size.width - 20
                            let height = geometry.size.height - 20
                            let stepX = width / CGFloat(data.count - 1)
                            
                            let value1 = data[index]
                            let value2 = data[index + 1]
                            
                            let x1 = CGFloat(index) * stepX + 10
                            let x2 = CGFloat(index + 1) * stepX + 10
                            
                            let normalizedValue1 = (value1 - 40) / (220 - 40)
                            let normalizedValue2 = (value2 - 40) / (220 - 40)
                            
                            let y1 = height - (CGFloat(normalizedValue1) * height) + 10
                            let y2 = height - (CGFloat(normalizedValue2) * height) + 10
                            
                            path.move(to: CGPoint(x: x1, y: y1))
                            path.addLine(to: CGPoint(x: x2, y: y2))
                        }
                        .stroke(heartRateColorForValue(data[index]), lineWidth: 2)
                    }
                }
            } else {
                Text("Collecting data...")
                    .foregroundColor(.white.opacity(0.5))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    func heartRateColorForValue(_ hr: Double) -> Color {
        if hr < 60 {
            return Color(red: 0, green: 0.0, blue: 0.6)
        } else if hr >= 60 && hr <= 90 {
            return Color(red: 0, green: 0.4, blue: 0)
        } else if hr > 90 && hr <= 110 {
            return Color(red: 0.65, green: 0.45, blue: 0)
        } else {
            return Color(red: 0.6, green: 0, blue: 0)
        }
    }
}

struct LabilityGraphView: View {
    let data: [Double]
    
    var body: some View {
        GeometryReader { geometry in
            if data.count > 1 {
                ZStack {
                    // Draw colored segments
                    ForEach(0..<data.count-1, id: \.self) { index in
                        Path { path in
                            let width = geometry.size.width - 20
                            let height = geometry.size.height - 20
                            let stepX = width / CGFloat(data.count - 1)
                            
                            let value1 = data[index]
                            let value2 = data[index + 1]
                            
                            let x1 = CGFloat(index) * stepX + 10
                            let x2 = CGFloat(index + 1) * stepX + 10
                            
                            let y1 = height - (CGFloat(value1) * height) + 10
                            let y2 = height - (CGFloat(value2) * height) + 10
                            
                            path.move(to: CGPoint(x: x1, y: y1))
                            path.addLine(to: CGPoint(x: x2, y: y2))
                        }
                        .stroke(labilityColorForValue(data[index]), lineWidth: 2)
                    }
                }
            } else {
                Text("Collecting data...")
                    .foregroundColor(.white.opacity(0.5))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    func labilityColorForValue(_ lability: Double) -> Color {
        if lability < 0.4 {
            return Color(red: 0, green: 0.4, blue: 0)
        } else if lability < 0.8 {
            return Color(red: 0.65, green: 0.45, blue: 0)
        } else {
            return Color(red: 0.6, green: 0, blue: 0)
        }
    }
}

struct GraphView: View {
    let data: [Double]
    let color: Color
    let minValue: Double
    let maxValue: Double
    
    var body: some View {
        GeometryReader { geometry in
            if data.count > 1 {
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let stepX = width / CGFloat(data.count - 1)
                    
                    for (index, value) in data.enumerated() {
                        let x = CGFloat(index) * stepX
                        let normalizedValue = (value - minValue) / (maxValue - minValue)
                        let y = height - (CGFloat(normalizedValue) * height)
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(color, lineWidth: 2)
                .padding(10)
            } else {
                Text("Collecting data...")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

struct WavyOvalShape: Shape {
    var lability: Double
    
    var animatableData: Double {
        get { lability }
        set { lability = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let points = 800
        let centerX = rect.midX
        let centerY = rect.midY
        let radiusX = rect.width / 2
        let radiusY = rect.height / 2
        
        for i in 0...points {
            let theta = Double(i) / Double(points) * 2 * .pi
            let r = shapeModulation(theta: theta, lability: lability)
            let x = centerX + r * cos(theta) * radiusX
            let y = centerY + r * sin(theta) * radiusY
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
    
    func shapeModulation(theta: Double, lability: Double) -> Double {
        // Amplitude: low when lability is low, high when lability is high
        let amplitudeMin = 0.01
        let amplitudeMax = 0.3
        let amplitude = amplitudeMin + (amplitudeMax - amplitudeMin) * pow(lability, 2)
        
        // Frequency: low when lability is low, high when lability is high
        let freqMin = 0.5
        let freqMax = 10.0
        let freq = freqMin + (freqMax - freqMin) * pow(lability, 2)
        
        // Wave shape varies with lability - increased wave count for more detail
        let spikiness = lability
        let waveCount = 12.0  // Increased from 6 to 12 for more waves
        let wave = (1 - spikiness) * sin(waveCount * theta) +
                   spikiness * (sin(waveCount * theta) > 0 ? 1 : -1) * abs(sin(waveCount * theta))
        
        // Use current time for continuous oscillation
        let timePhase = Date().timeIntervalSince1970
        
        return 1 + amplitude * sin(timePhase * .pi * freq) * wave
    }
}
