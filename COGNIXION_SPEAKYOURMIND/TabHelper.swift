//
//  TabHelper.swift
//  COGNIXION_SPEAKYOURMIND
//
//  Created by Dristi Roy on 5/6/25.
//
// TabHelper.swift
import SwiftUI

func switchToTab(named name: String, in tabs: [String], currentTab: Binding<Int>) {
    if let index = tabs.firstIndex(of: name) {
        currentTab.wrappedValue = index
    }
}
