//
//  DailyView.swift
//  TransLinkdle
//
//  Created by Kobe Shen on 2025-08-26.
//

import SwiftUI

struct DailyView: View {
    @State private var currentSchedule: Schedule?
    @State private var userGuess: Guess?
    @State private var showResult = false
    
    enum Guess {
        case earlier, later
    }
    
    var body: some View {
        VStack(spacing: 40) {
            if let schedule = currentSchedule {
                Text("Stop: \(schedule.stopName)")
                    .font(.title2)
                Text("Reference time: \(schedule.referenceTime)")
                    .font(.headline)
                
                HStack(spacing: 40) {
                    Button(action: {
                        userGuess = .earlier
                        showResult = true
                    }) {
                        VStack {
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.system(size: 50))
                            Text("Earlier")
                            
                        }
                    }
                    Button(action: {
                        userGuess = .later
                        showResult = true
                    }) {
                        VStack {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 50))
                            Text("Later")
                        }
                    }
                }
                
                if showResult, let guess = userGuess {
                    let isCorrect = checkGuess(guess, schedule: schedule)
                    VStack(spacing: 10) {
                        Text("Actual arrival: \(schedule.arrivalTime)")
                            .font(.headline)
                        Text(isCorrect ? "Correct" : "Incorrect")
                            .font(.title2)
                            .foregroundColor(isCorrect ? .green: .red)
                        Button("Next") {
                            loadRandomSchedule()
                        }
                        .padding(.top)
                    }
                }
            } else {
                Text("Loading...")
                    .onAppear {
                        loadRandomSchedule()
                    }
            }
        }
        .padding()
    }
    
    private func loadRandomSchedule() {
        let schedules = DatabaseManager.shared.fetchSchedules()
        currentSchedule = schedules.randomElement()
        userGuess = nil
        showResult = false
    }
    
    private func checkGuess(_ guess: Guess, schedule: Schedule) -> Bool {
        let ref = minutes(from: schedule.referenceTime)
        let arrival = minutes(from: schedule.arrivalTime)
        
        switch guess {
        case .earlier: return arrival < ref
        case .later: return arrival > ref
        }
    }
    
    private func minutes(from timeString: String) -> Int {
        let parts = timeString.split(separator: ":").compactMap { Int($0) }
        guard parts.count == 2 else { return 0 }
        return parts[0] * 60 + parts[1]
    }
}

#Preview {
    DailyView()
}
