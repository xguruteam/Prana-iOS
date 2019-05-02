//
//  Settings.swift
//  Prana
//
//  Created by Guru on 4/29/19.
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
    
    
    // Instant variable
    var currentDay: Int = 0
    
    init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        managedObjectContext = appDelegate.persistentContainer.viewContext
        clearSettings()
//        clearSessions()
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
        
        let result = NSManagedObject(entity: sessionEntity, insertInto: managedContext)
        result.setValue(session.duration, forKey: "duration")
        result.setValue(session.kind, forKey: "kind")
        result.setValue(session.mindful, forKey: "mindful")
        result.setValue(session.upright, forKey: "upright")
        
        do {
            try managedContext.save()
        }
        catch {
            print(error)
        }
    }
    
    func fetchSessions() -> [Session] {
        guard let managedContext = managedObjectContext else { return [] }
        let fetchRequest = NSFetchRequest<SessionManagedObject>(entityName: "Sessions")
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            let sessions = result.map(self.toSession)
            
            return sessions as! [Session]
        } catch let error as NSError {
            NSLog("Could not fetch readings. \(error), \(error.userInfo)")
        }
        return []
    }
    
    func toSession(_ object: SessionManagedObject) -> Session? {
        if let duration = object.value(forKey: "duration") as? Int,
            let mindful = object.value(forKey: "mindful") as? Int,
            let upright = object.value(forKey: "upright") as? Int,
            let kind = object.value(forKey: "kind") as? Int {
            
            return Session(duration: duration, kind: kind, mindful: mindful, upright: upright)
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
}
