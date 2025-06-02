//
//  GreetingView.swift
//  COGNIXION_SPEAKYOURMIND
//
//  Created by Dristi Roy on 5/6/25.
//
// GreetingView.swift

import SwiftUI
import AVFoundation
import ARKit
import Combine

let synthesizer = AVSpeechSynthesizer()
private let sessionQueue = DispatchQueue(label: "session queue")

//different moods
enum VoiceMood {
    case happy, sad, angry, calm
}

//use voice feature to speak input
func speak(_ text: String, mood: VoiceMood = .sad) {
    guard !synthesizer.isSpeaking else {
        print("Already speaking. Wait.") //for debug
        return
    }
    print("Speaking This: '\(text)'") //for debug
    let utterance = AVSpeechUtterance(string: text)
    utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
    
    //change voice characteristics to match the emotion
    switch mood {
        case .happy:
            utterance.rate = 0.55
            utterance.pitchMultiplier = 1.3
        case .sad:
            utterance.rate = 0.4
            utterance.pitchMultiplier = 0.8
        case .angry:
            utterance.rate = 0.6
            utterance.pitchMultiplier = 1.05
        case .calm:
            utterance.rate = 0.45
            utterance.pitchMultiplier = 0.9
    }
    
    synthesizer.speak(utterance)
}

//setup eye tracking using Vision
class EyeTrackerARKit: NSObject, ObservableObject, ARSessionDelegate {
    @Published var gazePoint: CGPoint = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY) //track eyes
    
    private var arSession = ARSession()
    
    override init() {
        super.init()
        arSession.delegate = self
    }
    
    //when user enters keyboard tab
    func start() {
        guard ARFaceTrackingConfiguration.isSupported else {
            print("ARFaceTracking not supported.")
            return
        }
        let configuration = ARFaceTrackingConfiguration()
        arSession.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    //when user goes back to home screen
    func stop() {
        arSession.pause()
    }
    
    //vector math to get the approximate eye coordinates.
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let faceAnchor = anchors.first as? ARFaceAnchor else { return }

        let leftEye = faceAnchor.leftEyeTransform
        let rightEye = faceAnchor.rightEyeTransform
        
        let eyeOrigin = simd_make_float4((leftEye.columns.3 + rightEye.columns.3) * 0.5)
        let leftDir = simd_normalize(simd_make_float4(leftEye.columns.2))
        let rightDir = simd_normalize(simd_make_float4(rightEye.columns.2))
        let eyeDirection = simd_normalize((leftDir + rightDir) * 0.5)

        let distance: Float = 0.4 //estimated distance from the screen
        let lookAtPoint3D = eyeOrigin + (eyeDirection * distance)
        
        DispatchQueue.main.async {
            self.gazePoint = self.convertToScreen(point3D: lookAtPoint3D) //get 2D from 3D approx
        }
    }
    
    private func convertToScreen(point3D: simd_float4) -> CGPoint {
        let screenSize = UIScreen.main.bounds.size
            
        let xMultiplier: CGFloat = 3 // Increase for more horizontal movement
        let yMultiplier: CGFloat = 3 // Increase for more vertical movement
            
        let x = ((CGFloat(point3D.x + 0.03) / 0.3) * xMultiplier) * screenSize.width
        let y = ((CGFloat(0.2 - point3D.y - 0.1) / 0.4) * yMultiplier) * screenSize.height
            
        return CGPoint(x: x, y: y)
    }
}

struct GreetingView: View {
    @Binding var currentTab: Int
    let tabs: [String]
    @StateObject private var eyeTracker = EyeTrackerARKit()
    @StateObject private var emotionManager = CameraEmotionManager()
    
    @State private var detectedMood: VoiceMood = .calm
    @State private var backgroundColor: Color = .white
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    @State private var gazeTimer: Timer? = nil
    @State private var focusedPhrase: String? = nil
    
    let phrases = [
        "Hello", "Goodbye", "Yes", "No",
        "Thank You", "No Thank You", "Hahahah", "I'm Tired",
        "I'm Happy", "I'm in Pain", "Please", "Water", "Next", "Previous"
    ]

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "hand.wave").imageScale(.large).foregroundStyle(.tint)
            Text("Greeting Options").font(.title).foregroundColor(.black).padding(.bottom, 10)

            HStack(spacing: 20) {
                Button { switchToTab(named: "Menu", in: tabs, currentTab: $currentTab)
                } label: { Label("Left Tab", systemImage: "arrow.left")
                }.padding()
                Button { switchToTab(named: "Letter", in: tabs, currentTab: $currentTab)
                } label: {Label("Right Tab", systemImage: "arrow.right")
                }.padding()
            }

            GeometryReader { geo in
                ZStack {
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(phrases, id: \.self) { phrase in
                            ZStack {
                                Button {
                                    analyzeAndSpeak(phrase)
                                } label: {
                                    Label(phrase, systemImage: "arrow.up")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue.opacity(0.2))
                                        .cornerRadius(10)
                                }.background(
                                    GeometryReader { btnGeo in
                                        Color.clear
                                            .onReceive(eyeTracker.$gazePoint) { gaze in
                                                let btnFrame = btnGeo.frame(in: .global)
                                                if btnFrame.contains(gaze) {
                                                    startGazeTimer(for: phrase)
                                                } else if focusedPhrase == phrase {
                                                    cancelGazeTimer()
                                                }
                                            }
                                    }
                                )

                                if focusedPhrase == phrase {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .scaleEffect(2.0)
                                        .frame(width: 40, height: 40)
                                }
                            }
                        }
                    }
                    
                    //eye track cursor
                    Circle()
                        .fill(Color.red.opacity(0.7))
                        .frame(width: 30, height: 30)
                        .position(eyeTracker.gazePoint)
                        .animation(.easeInOut(duration: 0.1), value: eyeTracker.gazePoint)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }.padding().background(backgroundColor.edgesIgnoringSafeArea(.all))
        .onAppear {
            eyeTracker.start()
            emotionManager.startSession()
            emotionManager.onMoodDetected = { mood in
                withAnimation { backgroundColor = moodColor(for: mood)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation {
                        backgroundColor = .white
                    }
                }
            }
        }.onDisappear {
            eyeTracker.stop()
            emotionManager.stopSession()
            cancelGazeTimer()
        }
    }

    func startGazeTimer(for phrase: String) {
        if focusedPhrase != phrase {
            cancelGazeTimer()
            focusedPhrase = phrase
            gazeTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                analyzeAndSpeak(phrase)
                focusedPhrase = nil
            }
        }
    }

    func cancelGazeTimer() {
        gazeTimer?.invalidate()
        gazeTimer = nil
        focusedPhrase = nil
    }

    @State private var lastSpokenPhrase: String? = nil
    @State private var canSpeak = true

    func analyzeAndSpeak(_ phrase: String) {
        guard canSpeak, phrase != lastSpokenPhrase else {
            print("Skipping repeated phrase: \(phrase)")
            return
        }
        
        emotionManager.capturePhoto()
        let mood = emotionManager.detectedMood
        print("Mood detected: \(mood)")
        
        withAnimation {
            backgroundColor = moodColor(for: mood)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                backgroundColor = .white
            }
        }
        
        speak(phrase, mood: mood)
        
        lastSpokenPhrase = phrase
        canSpeak = false
        
        // Cooldown period, e.g. 3 seconds, adjust as needed
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            canSpeak = true
            lastSpokenPhrase = nil
        }
    }

    func moodColor(for mood: VoiceMood) -> Color {
        switch mood {
            case .happy: return .yellow
            case .sad: return .blue
            case .angry: return .red
            case .calm: return .green
        }
    }
}
