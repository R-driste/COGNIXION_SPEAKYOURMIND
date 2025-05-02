
// ContentView.swift
import SwiftUI

struct ContentView: View {
    @Binding var currentTab: Int
    let tabs: [String]
    
    var body: some View {
        VStack {
            Text("SPEAK YOUR MIND")
                .font(.system(size: 30, weight: .light, design: .serif))
                .italic()
            Image(systemName: "mic")
                .imageScale(.large)
                .foregroundStyle(.tint)
            HStack(spacing: 20) {
                Button(action: {
                    switchToTab(named: "Letter", in: tabs, currentTab: $currentTab)
                }) {
                    Label("Left Tab", systemImage: "arrow.left")
                }.padding()
                Button(action: {
                    switchToTab(named: "Greet", in: tabs, currentTab: $currentTab)
                }) {
                    Label("Right Tab", systemImage: "arrow.right")
                }.padding()
            }
        }
        .padding()
    }
}
