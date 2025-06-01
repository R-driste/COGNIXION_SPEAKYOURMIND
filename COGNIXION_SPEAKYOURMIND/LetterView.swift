import SwiftUI
import AVFoundation

struct LetterView: View {
    @Binding var currentTab: Int
    let tabs: [String]
    
    @State private var count = 0
    @State private var typedText: String = ""
    
    let letterGroups = [
        "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O",
        "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", " "
    ]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            Image(systemName: "textformat.abc")
                .imageScale(.large)
                .foregroundStyle(.tint)
            
            Text("Letter Options")
                .font(.title)
                .padding(.bottom, 10)
            
            HStack(spacing: 20) {
                Button(action: {
                    switchToTab(named: "Greet", in: tabs, currentTab: $currentTab)
                }) {
                    Label("Left Tab", systemImage: "arrow.left")
                }.padding()
                
                Button(action: {
                    switchToTab(named: "Menu", in: tabs, currentTab: $currentTab)
                }) {
                    Label("Right Tab", systemImage: "arrow.right")
                }.padding()
            }
            
            Text("Typed: \(typedText)")
                .font(.headline)
                .padding(.vertical, 5)
            
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(letterGroups, id: \.self) { group in
                    Button(action: {
                        // Append first letter by default (can expand to cycle)
                        if let firstLetter = group.first {
                            typedText.append(firstLetter)
                        }
                    }) {
                        Text(group)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(10)
                    }
                }
            }
            .padding(.top)
            
            Button(action: {
                enterTypedText()
            }) {
                Label("Enter", systemImage: "return")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.3))
                    .cornerRadius(10)
            }
            .padding(.top)
            
            Button(action: signIn) {
                Label("Sign In", systemImage: "arrow.up")
            }
        }
        .padding()
    }
    
    func signIn() {
        count += 1
        print("Sign-in count: \(count)")
    }
    
    func enterTypedText() {
        print("Entered: \(typedText)")
        speak(typedText)
        typedText = ""
    }
}
