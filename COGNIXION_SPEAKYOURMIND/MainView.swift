//
//  MainView.swift
//  COGNIXION_SPEAKYOURMIND
//
//  Created by Dristi Roy on 5/6/25.
//
// MainView.swift
import SwiftUI

struct MainView: View {
    @State private var currentTab = 0
    private let tabs = ["Menu", "Greet", "Letter"]
    
    var body: some View {
        TabView(selection: $currentTab) {
            ContentView(currentTab: $currentTab, tabs: tabs)
                .tabItem {
                    Label("Menu", systemImage: "list.dash")
                }.tag(0)
            
            GreetingView(currentTab: $currentTab, tabs: tabs)
                .tabItem {
                    Label("Greet", systemImage: "square.and.pencil")
                }.tag(1)
             
            LetterView(currentTab: $currentTab, tabs: tabs)
                .tabItem {
                    Label("Letter", systemImage: "square.and.pencil")
                }.tag(2)
        }
    }
}

#Preview {
    MainView()
}
