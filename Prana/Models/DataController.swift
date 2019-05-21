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
                
                let vtString = try JSONEncoder().encode(vtPattern)
                settings.setValue(String(data:vtString, encoding: .utf8)!, forKey: "vtPattern")
                
                let btString = try JSONEncoder().encode(btPattern)
                settings.setValue(String(data:btString, encoding: .utf8)!, forKey: "btPattern")
                
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
    
    func addSessionRecord(_ session: Session) {
        guard let managedContext = managedObjectContext else { return }
        let sessionEntity = NSEntityDescription.entity(forEntityName: "Sessions", in: managedContext)!
        
        let result = SessionMO(entity: sessionEntity, insertInto: managedContext)
        result.startedAt = session.startedAt
        result.kind = Int32(session.kind)
        result.duration = Int32(session.duration)
        result.mindful = Int32(session.mindful)
        result.upright = Int32(session.upright)
        result.slouches = session.slouches.map {
            ["timeStamp" : $0.timeStamp]
        }
        
        result.breaths = session.breaths.map {
            ["timeStamp" : $0.timeStamp,
             "isMindful": $0.isMindful]
        }
        
        do {
            try managedContext.save()
        }
        catch {
            print(error)
        }
    }
    
    func fetchSessions() -> [Session] {
        guard let managedContext = managedObjectContext else { return [] }
        let fetchRequest = NSFetchRequest<SessionMO>(entityName: "Sessions")
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            let sessions = result.map(self.toSession)
            
            return sessions as! [Session]
        } catch let error as NSError {
            NSLog("Could not fetch readings. \(error), \(error.userInfo)")
        }
        return []
    }
    
    func toSession(_ object: SessionMO) -> Session? {
        if let duration = object.value(forKey: "duration") as? Int,
            let mindful = object.value(forKey: "mindful") as? Int,
            let upright = object.value(forKey: "upright") as? Int,
            let kind = object.value(forKey: "kind") as? Int,
        let startedAt = object.startedAt {
            let session = Session(startedAt: startedAt, kind: kind)
            session.duration = duration
            session.mindful = mindful
            session.upright = upright
            session.slouches = object.slouches!.map({ (item) -> SlouchRecord in
                return SlouchRecord(item["timeStamp"] as! Int)
            })
            session.breaths = object.breaths!.map({ (item) -> BreathRecord in
                return BreathRecord(timeStamp: item["timeStamp"] as! Int, isMindful: item["isMindful"] as! Bool)
            })
            return session
        }
        return nil
    }
    
    func clearSessions() {
        guard let managedContext = managedObjectContext else { return }
        let fetchRequest = NSFetchRequest<SessionManagedObject>(entityName: "Sessions")
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
