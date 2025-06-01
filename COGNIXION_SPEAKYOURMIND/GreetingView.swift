//
//  GreetingView.swift
//  COGNIXION_SPEAKYOURMIND
//
//  Created by Dristi Roy on 5/6/25.
//
// GreetingView.swift

import SwiftUI
import Vision
import AVFoundation

let synthesizer = AVSpeechSynthesizer()
private let sessionQueue = DispatchQueue(label: "session queue")

//different moods
enum VoiceMood {
    case happy, sad, angry, calm
}

//use voice feature to speak input
func speak(_ text: String, mood: VoiceMood = .sad) {
    print("Speak works vision fails")
    guard !synthesizer.isSpeaking else {
        print("Already speaking. Wait.") //for debug
        return
    }
    print("Speaking: \(text)") //for debug
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
class EyeTracker: NSObject, ObservableObject {
    @Published var gazePoint = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY) //position of user focus
    
    private let captureSession = AVCaptureSession()
    private let sequenceHandler = VNSequenceRequestHandler()
    private let queue = DispatchQueue(label: "EyeTrackingQueue")
    
    //start tracking when entering tab
    func start() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("No front camera found")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)
            captureSession.beginConfiguration()
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            let output = AVCaptureVideoDataOutput()
            output.setSampleBufferDelegate(self, queue: queue)
            if captureSession.canAddOutput(output) {
                captureSession.addOutput(output)
            }
            captureSession.commitConfiguration()
            sessionQueue.async {
                self.captureSession.startRunning()
            }
        } catch {
            print("Error setting up camera input: \(error)")
        }
    }

    //stop tracking when switching tab
    func stop() {
        sessionQueue.async {
            self.captureSession.stopRunning()
        }
    }

    private func handleFaceLandmarks(_ landmarks: VNFaceLandmarks2D?, in boundingBox: CGRect) {
        guard let landmarks = landmarks else { return }
        let leftPoint = landmarks.leftPupil?.normalizedPoints.first ?? landmarks.leftEye?.normalizedPoints.first
        let rightPoint = landmarks.rightPupil?.normalizedPoints.first ?? landmarks.rightEye?.normalizedPoints.first

        guard let left = leftPoint, let right = rightPoint else { return }

        let avgX = (left.x + right.x) / 2
        let avgY = (left.y + right.y) / 2
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height

        let gazeX = (boundingBox.origin.x + avgX * boundingBox.size.width) * screenWidth
        let gazeY = (1 - (boundingBox.origin.y + avgY * boundingBox.size.height)) * screenHeight

        DispatchQueue.main.async {
            self.gazePoint = CGPoint(x: gazeX, y: gazeY)
        }
    }
}

extension EyeTracker: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let request = VNDetectFaceLandmarksRequest { [weak self] request, error in
            guard let self = self,
                  let results = request.results as? [VNFaceObservation],
                  let face = results.first else {
                return
            }
            self.handleFaceLandmarks(face.landmarks, in: face.boundingBox)
        }

        request.revision = VNDetectFaceLandmarksRequestRevision3

        do {
            try sequenceHandler.perform([request], on: pixelBuffer)
        } catch {
            print("Vision error: \(error)")
        }
    }
}

struct GreetingView: View {
    @Binding var currentTab: Int
    let tabs: [String]
    @StateObject private var eyeTracker = EyeTracker()
    
    let phrases = [
        "Hello", "Goodbye", "Yes", "No",
        "Thank You", "No Thank You", "Hahahah", "I'm Tired",
        "I'm Happy", "I'm in Pain", "Please", "Water"
    ]

    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    @State private var gazeTimer: Timer? = nil
    @State private var focusedPhrase: String? = nil
    @State private var backgroundColor: Color = .white

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "hand.wave")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Greeting Options")
                .font(.title)
                .padding(.bottom, 10)
            HStack(spacing: 20) {
                Button(action: {
                    switchToTab(named: "Menu", in: tabs, currentTab: $currentTab)
                }) {
                    Label("Left Tab", systemImage: "arrow.left")
                }.padding()
                Button(action: {
                    switchToTab(named: "Letter", in: tabs, currentTab: $currentTab)
                }) {
                    Label("Right Tab", systemImage: "arrow.right")
                }.padding()
            }
            
            GeometryReader { geo in
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(phrases, id: \.self)
                    { phrase in
                        ZStack {
                            Button(action: {
                                analyzeAndSpeak(phrase)
                            }) {
                                Label(phrase, systemImage: "arrow.up")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(10)
                            }
                            .background(
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
                    Circle()
                        .fill(Color.red.opacity(0.7))
                        .frame(width: 30, height: 30)
                        .position(eyeTracker.gazePoint)
                        .animation(.easeInOut(duration: 0.1), value: eyeTracker.gazePoint)
                }
            }
        }
        .padding()
        .background(backgroundColor.edgesIgnoringSafeArea(.all))
        .onAppear {
            eyeTracker.start()
        }
        .onDisappear {
            eyeTracker.stop()
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

    func analyzeAndSpeak(_ phrase: String) {
        let mood = detectEmotion()
        withAnimation {
            backgroundColor = moodColor(for: mood)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                backgroundColor = .white
            }
        }
        speak(phrase, mood: mood)
    }

    func detectEmotion() -> VoiceMood {
        return [.happy, .sad, .angry, .calm].randomElement()!
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
