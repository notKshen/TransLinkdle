//
//  ContentView.swift
//  TransLinkdle
//
//  Created by Kobe Shen on 2025-08-26.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = "daily"
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("", systemImage: "questionmark.circle.fill", value: "daily") {
                DailyView()
            }
            Tab("", systemImage: "tram.fill", value: "transit") {
                TransitView()
            }
        }
        .tint(selectedTab == "daily" ? .dailyBlue : .transitGreen)
        .animation(.easeInOut(duration: 0.4), value: selectedTab)
        
    }
}


#Preview {
    ContentView()
}
