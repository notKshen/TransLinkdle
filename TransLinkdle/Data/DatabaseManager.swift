//
//  DatabaseManager.swift
//  TransLinkdle
//
//  Created by Kobe Shen on 2025-08-31.
//

import Foundation
import SQLite3

struct Schedule {
    let stopName: String
    let busNumber: String
    let referenceTime: String
    let arrivalTime: String
}

class DatabaseManager {
    static let shared = DatabaseManager()
    private var db: OpaquePointer?
    
    private init() {
        copyDatabaseIfNeeded()
        openDatabase()
    }
    
    var dbPath: String {
        let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDir.appendingPathComponent("transit.db").path
    }
    
    private func copyDatabaseIfNeeded() {
        let fileManager = FileManager.default
        let dbName = "transit.db"
        
        let documentsURL = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let destinationURL = documentsURL.appendingPathComponent(dbName)
        
        guard !fileManager.fileExists(atPath: destinationURL.path) else {
            print("Database file already exists at destination")
            return
        }
        
        if let bundleURL = Bundle.main.url(forResource: "transit", withExtension: "db") {
            do {
                try fileManager.copyItem(at: bundleURL, to: destinationURL)
                print("Copied transit.db to Documents directory")
            } catch {
                print("Failed to copy database: \(error.localizedDescription)")
            }
        } else {
            print( "Database file not found in bundle.")
        }
    }
    
    private func openDatabase() {
        let fileManager = FileManager.default
        let dbName = "transit.db"
        let documentsURL = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let dbPath = documentsURL.appendingPathComponent(dbName).path
        
        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            print( "Database opened successfully")
        } else {
            print( "Unable to open database")
        }
    }
    
    func fetchAllStops() -> [String] {
        var stops: [String] = []
        let query = "SELECT stop_name FROM schedules;"
        
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                if let cString = sqlite3_column_text(statement, 0) {
                    stops.append(String(cString: cString))
                }
            }
            sqlite3_finalize(statement)
        } else {
            print("Error preparing fetch statement")
        }
        
        return stops
    }
}

extension DatabaseManager {
    func fetchSchedules() -> [Schedule] {
        var schedules: [Schedule] = []
        let query = "SELECT stop_name, bus_number, reference_time, arrival_time FROM schedules;"

        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let stopName = String(cString: sqlite3_column_text(statement, 0))
                let busNumber = String(cString: sqlite3_column_text(statement, 1))
                let referenceTime = String(cString: sqlite3_column_text(statement, 2))
                let arrivalTime = String(cString: sqlite3_column_text(statement, 3))

                let schedule = Schedule(stopName: stopName, busNumber: busNumber, referenceTime: referenceTime, arrivalTime: arrivalTime)
                schedules.append(schedule)
            }
            sqlite3_finalize(statement)
        } else {
            print("Error preparing fetchSchedules statement")
        }

        return schedules
    }
}
