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

//simulate different emotions
enum VoiceMood {
    case happy, sad, angry, calm
}
func speak(_ text: String, mood: VoiceMood = .sad) {
    guard !synthesizer.isSpeaking else {
        print("Already speaking. Wait.")
        return
    }
    
    print("Speaking this text: \(text)")
    let utterance = AVSpeechUtterance(string: text)
    utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
    
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

struct GreetingView: View {
    @Binding var currentTab: Int
    let tabs: [String]
    
    let phrases = [
        "Hello", "Goodbye", "Yes", "No",
        "Thank You", "No Thank You", "Hahahah", "I'm Tired",
        "I'm Happy", "I'm in Pain", "Please", "Water"
    ]
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
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
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(phrases, id: \.self) { phrase in
                    Button(action: { speak(phrase) }) {
                        Label(phrase, systemImage: "arrow.up")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding()
    }
}
