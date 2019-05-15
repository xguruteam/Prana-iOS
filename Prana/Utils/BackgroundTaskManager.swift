//
//  BackgroundTaskManager.swift
//  Prana
//
//  Created by Luccas on 5/15/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import Foundation
import UIKit

class BackgroundTaskManager: NSObject {
    
    static let shared = BackgroundTaskManager()
    
    var bgTaskIdList: [UIBackgroundTaskIdentifier] = []
    var masterTaskId: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    
    func beginNewBackgroundTask() -> UIBackgroundTaskIdentifier {
        
        let application = UIApplication.shared
        var bgTaskId: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
        
        if application.responds(to: #selector(UIApplication.beginBackgroundTask(withName:expirationHandler:))) {
            bgTaskId = application.beginBackgroundTask(expirationHandler: {
                [weak self] in
                //Log("background task \(bgTaskId) expired")
                guard let index = self?.bgTaskIdList.index(of: bgTaskId) else {
                    //Log("Invaild Task \(bgTaskId)")
                    return
                }
                application.endBackgroundTask(bgTaskId)
                self?.bgTaskIdList.remove(at: index)
            })
            
            if self.masterTaskId == UIBackgroundTaskIdentifier.invalid {
                self.masterTaskId = bgTaskId
                //Log("start master task \(bgTaskId)")
            }
            else {
                //Log("started background task \(bgTaskId)")
                self.bgTaskIdList.append(bgTaskId)
                self.endBackgroundTasks()
            }
        }
        return bgTaskId
    }
    
    func endBackgroundTasks() {
        self.drainBGTaskList(all: false)
    }
    
    func endAllBackgroundTasks() {
        self.drainBGTaskList(all: true)
    }
    
    func drainBGTaskList(all: Bool) {
        let application = UIApplication.shared
        if application.responds(to: #selector(UIApplication.endBackgroundTask(_:))) {
            let count = self.bgTaskIdList.count
            for _ in (all ? 0 : 1) ..< count {
                let bgTaskId = self.bgTaskIdList[0]
                //Log("ending background task with id\(bgTaskId)")
                application.endBackgroundTask(bgTaskId)
                self.bgTaskIdList.remove(at: 0)
            }
            
            if self.bgTaskIdList.count > 0 {
                //Log("kept background task id \(self.bgTaskIdList[0])")
            }
            
            if all {
                //Log("no more background tasks running")
                application.endBackgroundTask(self.masterTaskId)
                self.masterTaskId = UIBackgroundTaskIdentifier.invalid
            }
            else {
                //Log("kept master background task id \(self.masterTaskId)")
            }
        }
    }
}

