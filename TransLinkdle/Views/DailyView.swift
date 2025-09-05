//
//  DailyView.swift
//  TransLinkdle
//
//  Created by Kobe Shen on 2025-08-26.
//

import SwiftUI
import UIKit

struct DailyView: View {
    @State private var currentSchedule: Schedule?
    @State private var guessText: String = ""
    @State private var guesses: [GuessResult] = []
    @State private var gameOver = false
    @State private var isShareSheetPresented: Bool = false
    @FocusState private var isFocused: Bool
    
    private let maxGuesses = 5
    
    struct GuessResult: Identifiable {
        let id = UUID()
        let text: String
        let feedback: Image
    }
    
    var body: some View {
        
        VStack(spacing: 25) {
            if let schedule = currentSchedule {
                VStack (alignment: .center) {
                    Image(.bus)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    Text("Stop: \(schedule.busNumber) \(schedule.stopName)")
                        .multilineTextAlignment(.center)
                        .font(.title2)
                        .foregroundColor(.white)
                    Text("Reference time: \(schedule.referenceTime)")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.gray.opacity(0.5))
                        .stroke(Color.gray, lineWidth: 2)
                        .shadow(color: Color.white.opacity(0.5), radius: 5, x: 0, y: 7)
                )
                
                Text("Guess: \(guesses.count)/\(maxGuesses) ")
                    .font(.title2)
                
                VStack(spacing: 10) {
                    ForEach(0..<maxGuesses, id: \.self) { index in
                        let result = index < guesses.count ? guesses[index] : nil
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(result != nil
                                      ? (result!.feedback == Image(systemName: "checkmark") ? Color.green : Color.red)
                                      : Color.gray.opacity(0.3))
                            
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 2)
                            
                            if let result = result {
                                Text(result.text)
                                    .font(.system(size: 20, weight: .medium))
                                
                                HStack {
                                    Spacer()
                                    result.feedback
                                        .font(.system(size: 20, weight: .medium))
                                        .frame(width: 30)
                                }
                                .padding(.horizontal, 10)
                            }
                        }
                        .frame(height: 45)
                        
                    }
                    if !gameOver {
                        HStack {
                            TextField(isFocused ? "00:00" : "Enter a guess...", text: $guessText)
                                .keyboardType(.numbersAndPunctuation)
                                .padding(11)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(.gray.opacity(0.3))
                                        .stroke(Color.gray, lineWidth: 2)
                                )
                                .focused($isFocused)
                            
                            Button("Submit") {
                                submitGuess(schedule: schedule)
                            }
                            .foregroundStyle(.dailyBlue)
                            .buttonStyle(.bordered)
                            .disabled(guessText.isEmpty || guesses.count >= maxGuesses)
                        }
                    } else {
                        Button(action: {
                            isShareSheetPresented = true
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share")
                            }
                            .padding(.vertical, 5)
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.capsule)
                        .foregroundStyle(.dailyBlue)
                        .sheet(isPresented: $isShareSheetPresented) {
                            if let busUIImage = UIImage(named: "Bus") {
                                ShareSheet(items: ["I scored \(guesses.count)/\(maxGuesses) on Translinkdle! 🌟", busUIImage])
                            }
                            
                        }
                        
                        
                    }
                }
            } else {
                Text("Loading...")
                    .onAppear {
                        loadRandomSchedule()
                    }
            }
        }
        .padding(50)
    }
    
    
    private func loadRandomSchedule() {
        let schedules = DatabaseManager.shared.fetchSchedules()
        currentSchedule = schedules.randomElement()
        guessText = ""
        guesses = []
        gameOver = false
    }
    
    private func submitGuess(schedule: Schedule) {
        let actual = minutes(from: schedule.arrivalTime)
        guard let guessMinutes = minutes(from: guessText) else { return }
        
        let feedback: Image
        if guessMinutes == actual {
            feedback = Image(systemName: "checkmark")
            gameOver = true
        } else if guessMinutes < actual! {
            feedback = Image(systemName: "arrow.up")
        } else {
            feedback = Image(systemName: "arrow.down")
        }
        
        guesses.append(GuessResult(text: guessText, feedback: feedback))
        guessText = ""
        
        if guesses.count >= maxGuesses {
            gameOver = true
        }
    }
    
    private func minutes(from timeString: String) -> Int? {
        let parts = timeString.split(separator: ":").compactMap { Int($0) }
        guard parts.count == 2 else { return nil }
        return parts[0] * 60 + parts[1]
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    DailyView()
}
