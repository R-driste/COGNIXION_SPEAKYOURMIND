//
//  GreetingView.swift
//  COGNIXION_SPEAKYOURMIND
//
//  Created by Dristi Roy on 5/6/25.
//

// GreetingView.swift
import SwiftUI

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
    
    func speak(_ text: String) {
        print("Speaking: \(text)")
    }
}
