//
//  Settings.swift
//  Prana
//
//  Created by Luccas on 4/29/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import SwiftyJSON
import Firebase
import Crashlytics
import Fabric

typealias SettingsManagedObject = NSManagedObject
typealias SessionManagedObject = NSManagedObject

class DataController {
    var managedObjectContext: NSManagedObjectContext? = nil
    
    
    
    // Settings
    var isDevicePaired: Bool = false
    var isTutorialPassed: Bool = false
    var programType: Int = 100
    var dailyNotification: Date?
    var breathingGoals: Int = 0
    var postureGoals: Int = 0
    
    var vtPattern: SavedPattern?
    var btPattern: SavedPattern?
    var savedBodyNotification: SavedBodyNotification?
    
    var sessionSettings: SessionSettings?
    
    
    // Instant variable
    var currentDay: Int {
        if let program = currentProgram {
            if program.type == .fourteen {
                let calendar = Calendar.current
                
                // Replace the hour (time) of both dates with 00:00
                let date1 = calendar.startOfDay(for: program.startedAt)
                let date2 = calendar.startOfDay(for: Date())
                
                let components = calendar.dateComponents([.day], from: date1, to: date2)
                return components.day ?? 0
            }
            else {
                return 0
            }
        }
        else {
            return 0
        }
    }
    
    var currentProgram: Program? {
        guard let lastProgram = self.fetchPrograms().last else { return nil }
        
        if lastProgram.status == "inprogress" { return lastProgram }
        
        return nil
    }
    
    init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        managedObjectContext = appDelegate.persistentContainer.viewContext
        #if TEST_MODE
//        clearSettings()
//        clearPrograms()
//        clearSessions()
//        clearLocalDB()
        #endif
        loadSettings()
    }
    
    func loadSettings() {
        guard let managedContext = managedObjectContext else { return }
        let fetchRequest = NSFetchRequest<SettingsManagedObject>(entityName: "Settings")
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            
            if let settings = result.first {
                isDevicePaired = settings.value(forKey: "isDevicePaired") as! Bool
                isTutorialPassed = settings.value(forKey: "isTutorialPassed") as! Bool
                programType = settings.value(forKey: "programType") as! Int
                dailyNotification = settings.value(forKey: "dailyNotification") as? Date
                breathingGoals = settings.value(forKey: "breathingGoals") as! Int
                postureGoals = settings.value(forKey: "postureGoals") as! Int
                if let vtString = settings.value(forKey: "vtPattern") as? String {
                    vtPattern = try JSONDecoder().decode(SavedPattern.self, from: vtString.data(using: .utf8)!)
                }
                if let btString = settings.value(forKey: "btPattern") as? String {
                    btPattern = try JSONDecoder().decode(SavedPattern.self, from: btString.data(using: .utf8)!)
                }

                if let bnString = settings.value(forKey: "savedBodyNotification") as? String {
                    savedBodyNotification = try JSONDecoder().decode(SavedBodyNotification.self, from: bnString.data(using: .utf8)!)
                }

                if let sessionSettingsString = settings.value(forKey: "sessionSettings") as? String {
                    sessionSettings = try JSONDecoder().decode(SessionSettings.self, from: sessionSettingsString.data(using: .utf8)!)
                }
            }
            else {
                let settingsEntity = NSEntityDescription.entity(forEntityName: "Settings", in: managedContext)!
                
                let settings = SettingsManagedObject(entity: settingsEntity, insertInto: managedContext)
                settings.setValue(isDevicePaired, forKey: "isDevicePaired")
                settings.setValue(isTutorialPassed, forKey: "isTutorialPassed")
                settings.setValue(programType, forKey: "programType")
                settings.setValue(dailyNotification, forKey: "dailyNotification")
                settings.setValue(breathingGoals, forKey: "breathingGoals")
                settings.setValue(postureGoals, forKey: "postureGoals")
                
                vtPattern = SavedPattern(type: 0)
                btPattern = SavedPattern(type: 0)
                
                savedBodyNotification = SavedBodyNotification()
                
                let vtString = try JSONEncoder().encode(vtPattern)
                settings.setValue(String(data:vtString, encoding: .utf8)!, forKey: "vtPattern")
                
                let btString = try JSONEncoder().encode(btPattern)
                settings.setValue(String(data:btString, encoding: .utf8)!, forKey: "btPattern")
                
                let bnString = try JSONEncoder().encode(savedBodyNotification)
                settings.setValue(String(data:bnString, encoding: .utf8)!, forKey: "savedBodyNotification")
                
                sessionSettings = SessionSettings()
                
                let sessionSettingsString = try JSONEncoder().encode(sessionSettings)
                settings.setValue(String(data:sessionSettingsString, encoding: .utf8)!, forKey: "sessionSettings")
                
                do {
                    try managedContext.save()
                }
                catch {
                    print(error)
                }
            }
            
        } catch let error as NSError {
            NSLog("Could not fetch Settings. \(error), \(error.userInfo)")
        }
    }
    
    func saveSettings() {
        guard let managedContext = managedObjectContext else { return }
        let fetchRequest = NSFetchRequest<SettingsManagedObject>(entityName: "Settings")
        do {
            let result = try managedContext.fetch(fetchRequest)
            
            if let settings = result.first {
                settings.setValue(isDevicePaired, forKey: "isDevicePaired")
                settings.setValue(isTutorialPassed, forKey: "isTutorialPassed")
                settings.setValue(programType, forKey: "programType")
                settings.setValue(dailyNotification, forKey: "dailyNotification")
                settings.setValue(breathingGoals, forKey: "breathingGoals")
                settings.setValue(postureGoals, forKey: "postureGoals")
                
                let vtString = try JSONEncoder().encode(vtPattern)
                settings.setValue(String(data:vtString, encoding: .utf8)!, forKey: "vtPattern")
                
                let btString = try JSONEncoder().encode(btPattern)
                settings.setValue(String(data:btString, encoding: .utf8)!, forKey: "btPattern")
                
                let bnString = try JSONEncoder().encode(savedBodyNotification)
                settings.setValue(String(data:bnString, encoding: .utf8)!, forKey: "savedBodyNotification")
                
                let sessionSettingsString = try JSONEncoder().encode(sessionSettings)
                settings.setValue(String(data:sessionSettingsString, encoding: .utf8)!, forKey: "sessionSettings")
                
                do {
                    try managedContext.save()
                }
                catch {
                    print(error)
                }
            }
        } catch {
            print(error)
        }
    }
    
    func clearSettings() {
        guard let managedContext = managedObjectContext else { return }
        let fetchRequest = NSFetchRequest<SettingsManagedObject>(entityName: "Settings")
        do {
            let result = try managedContext.fetch(fetchRequest)
            
            if let settings = result.first {
                managedContext.delete(settings)
                
                do {
                    try managedContext.save()
                }
                catch {
                    print(error)
                }
            }
        } catch {
            print(error)
        }
    }
    
    func addRecord(training session: TrainingSession) {
        guard let managedContext = managedObjectContext else { return }
        do {
            let sessionEntity = NSEntityDescription.entity(forEntityName: "LocalDB", in: managedContext)!
            
            let result = LocalDB(entity: sessionEntity, insertInto: managedContext)
            result.id = UUID().uuidString
            result.type = "TS"
            result.time = session.startedAt
            
            let data = try JSONEncoder().encode(session)
            result.data = String(data:data, encoding: .utf8)!
            
            result.flag = true
            
            try managedContext.save()
        }
        catch {
            Crashlytics.sharedInstance().recordError(error)
            print(error)
        }
    }
    
    func addRecord(passive session: PassiveSession) {
        guard let managedContext = managedObjectContext else { return }
        do {
            let sessionEntity = NSEntityDescription.entity(forEntityName: "LocalDB", in: managedContext)!
            
            let result = LocalDB(entity: sessionEntity, insertInto: managedContext)
            result.id = UUID().uuidString
            result.type = "PS"
            result.time = session.startedAt
            
            let data = try JSONEncoder().encode(session)
            result.data = String(data:data, encoding: .utf8)!
            
            result.flag = true
            
            try managedContext.save()
        }
        catch {
            Crashlytics.sharedInstance().recordError(error)
            print(error)
        }
    }
    
    func addRecord(body measurement: Measurement) {
        guard let managedContext = managedObjectContext else { return }
        let fetchRequest = NSFetchRequest<LocalDB>(entityName: "LocalDB")
        let date = measurement.date
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            
            let todayMeasurement = result.filter { (object) -> Bool in
                guard object.type == "BM" else { return false }
                
                guard let createdAt = object.time else { return false }
                let diffInDays = Calendar.current.dateComponents([.day], from: createdAt, to: date).day
                guard diffInDays == 0 else { return false }
                return true
            }.first
            
            if let object = todayMeasurement {
                object.time = date
                let data = try JSONEncoder().encode(measurement)
                object.data = String(data:data, encoding: .utf8)!
                object.flag = true
            }
            else {
                let sessionEntity = NSEntityDescription.entity(forEntityName: "LocalDB", in: managedContext)!
                
                let result = LocalDB(entity: sessionEntity, insertInto: managedContext)
                result.id = UUID().uuidString
                result.type = "BM"
                result.time = measurement.date
                
                let data = try JSONEncoder().encode(measurement)
                result.data = String(data:data, encoding: .utf8)!
                
                result.flag = true
            }
            
            
            try managedContext.save()
        }
        catch {
            Crashlytics.sharedInstance().recordError(error)
            print(error)
        }
    }
    
    func fetchDailySessions(date: Date) -> [AnyObject] {
        guard let managedContext = managedObjectContext else { return [] }
        let fetchRequest = NSFetchRequest<LocalDB>(entityName: "LocalDB")
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            let sessions = result.filter { (object) -> Bool in
                guard object.type == "TS" || object.type == "PS" else { return false }
                
                guard let createdAt = object.time else { return false }
                let diffInDays = Calendar.current.dateComponents([.day], from: createdAt, to: date).day
                guard diffInDays == 0 else { return false }
                return true
                }.map { (object) -> AnyObject in
                    let data = object.data!
                    do {
                        if object.type == "TS" {
                            let session = try JSONDecoder().decode(TrainingSession.self, from: data.data(using: .utf8)!)
                            return session
                        } else {
                            let session = try JSONDecoder().decode(PassiveSession.self, from: data.data(using: .utf8)!)
                            return session
                        }
                    } catch {
                        Crashlytics.sharedInstance().recordError(error)
                    }
                    return TrainingSession(startedAt: Date(), type: 0, kind: 0, pattern: 0, wearing: 0)
            }
            return sessions
            
        } catch let error as NSError {
            NSLog("Could not fetch readings. \(error), \(error.userInfo)")
        }
        
        return []
    }
    
    func fetchDailyMeasurement(date: Date) -> Measurement? {
        guard let managedContext = managedObjectContext else { return nil }
        let fetchRequest = NSFetchRequest<LocalDB>(entityName: "LocalDB")
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            let sessions = result.filter { (object) -> Bool in
                guard object.type == "BM" else { return false }
                
                guard let createdAt = object.time else { return false }
                let diffInDays = Calendar.current.dateComponents([.day], from: createdAt, to: date).day
                guard diffInDays == 0 else { return false }
                return true
                }.map { (object) -> Measurement? in
                    let data = object.data!
                    do {
                        let measurement = try JSONDecoder().decode(Measurement.self, from: data.data(using: .utf8)!)
                        return measurement
                    } catch {
                        Crashlytics.sharedInstance().recordError(error)
                    }
                    return nil
            }
            guard let last = sessions.last else { return nil }
            return last
            
        } catch let error as NSError {
            NSLog("Could not fetch readings. \(error), \(error.userInfo)")
        }
        
        return nil
    }
    
    func clearLocalDB() {
        guard let managedContext = managedObjectContext else { return }
        let fetchRequest = NSFetchRequest<LocalDB>(entityName: "LocalDB")
        do {
            let result = try managedContext.fetch(fetchRequest)
            
            result.each { (_, session) in
                managedContext.delete(session)
                
                do {
                    try managedContext.save()
                }
                catch {
                    print(error)
                }
            }
        } catch {
            print(error)
        }
    }
    
    func startProgram(_ program: Program) {
        guard let managedContext = managedObjectContext else { return }
        let programEntity = NSEntityDescription.entity(forEntityName: "Programs", in: managedContext)!
        
        let result = ProgramMO(entity: programEntity, insertInto: managedContext)
        result.startedAt = program.startedAt
        result.type = program.type.toString()
        result.endAt = program.endedAt
        result.status = program.status
        
        do {
            try managedContext.save()
        }
        catch {
            print(error)
        }
    }
    
    func endProgram(_ program: Program) {
        guard let managedContext = managedObjectContext else { return }
        let fetchRequest = NSFetchRequest<ProgramMO>(entityName: "Programs")
        fetchRequest.predicate = NSPredicate(format: "startedAt == %@", program.startedAt as NSDate)
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            guard result.count == 1 else {
                fatalError()
                return
            }
            
            if let object = result.last {
                object.endAt = program.endedAt
                object.status = program.status
                
                do {
                    try managedContext.save()
                }
                catch {
                    print(error)
                }
            }
            
        } catch let error as NSError {
            NSLog("Could not fetch readings. \(error), \(error.userInfo)")
        }
    }
    
    func fetchPrograms() -> [Program] {
        guard let managedContext = managedObjectContext else { return [] }
        let fetchRequest = NSFetchRequest<ProgramMO>(entityName: "Programs")
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            let programs = result.map(self.toProgram)
            
            return programs as! [Program]
        } catch let error as NSError {
            NSLog("Could not fetch readings. \(error), \(error.userInfo)")
        }
        return []
    }
    
    func toProgram(_ object: ProgramMO) -> Program? {
        if let type = ProgramType(from: object.type),
            let startedAt = object.startedAt,
            let status = object.status {
            let program = Program(type: type)
            program.startedAt = startedAt
            program.endedAt = object.endAt
            program.status = status
            
            return program
        }
        
        return nil
    }
    
    func clearPrograms() {
        guard let managedContext = managedObjectContext else { return }
        let fetchRequest = NSFetchRequest<ProgramMO>(entityName: "Programs")
        do {
            let result = try managedContext.fetch(fetchRequest)
            
            result.each { (_, session) in
                managedContext.delete(session)
                
                do {
                    try managedContext.save()
                }
                catch {
                    print(error)
                }
            }
        } catch {
            print(error)
        }
    }
}
