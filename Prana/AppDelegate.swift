//
//  AppDelegate.swift
//  Prana
//
//  Created by Luccas on 2019/2/27.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift
import Firebase

extension Notification.Name {
    static let connectViewControllerDidNext = Notification.Name("connectViewControllerDidNext")
    static let connectViewControllerDidNextToSession = Notification.Name("connectViewControllerDidNextToSession")
    static let tutorialDidEnd = Notification.Name("tutorialDidEnd")
    static let didLogIn = Notification.Name("didLogIn")
    static let landscapeViewControllerDidDismiss = Notification.Name("landscapeViewControllerDidDismiss")
    static let visualViewControllerEndSession = Notification.Name("visualViewControllerEndSession")
    static let deviceOrientationDidChange = UIDevice.orientationDidChangeNotification
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var token:String = ""
    
    var dataController: DataController!
    
    let notifications = Notifications()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        Fabric.sharedSDK().debug = true

        // Override point for customization after application launch.
        dataController = DataController()
        
        IQKeyboardManager.shared.enable = true
        PranaDeviceManager.shared.prepare()
        
        notifications.center.delegate = notifications
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        guard dataController.isAutoDisconnect else { return }
        
        if let _ = topViewControllerWithRootViewController(rootViewController: window?.rootViewController) as? PassiveTrackingViewController {
            print("applicationDidEnterBackground when topViewController is passive")
        } else {
            print("applicationDidEnterBackground when topViewController is not passive")
            
            if PranaDeviceManager.shared.isConnected {
                PranaDeviceManager.shared.stopGettingLiveData()
                PranaDeviceManager.shared.disconnect()
            }
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        notifications.applicationDidBecomeActive()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        self.saveContext()
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if let scheme = url.scheme,
            scheme.localizedCaseInsensitiveCompare("app.prana.com") == .orderedSame,
            let _ = url.host {
            
            var parameters: [String: String] = [:]
            URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.forEach {
                parameters[$0.name] = $0.value
            }
            
            print(parameters)
            token = parameters["token"]!
            
            if let rootViewController = self.topViewControllerWithRootViewController(rootViewController: window?.rootViewController) {
                let vc = Utils.getStoryboardWithIdentifier(identifier: "ResetPasswordViewController")
                let nc = UINavigationController(rootViewController: vc)
                rootViewController.present(nc, animated: true, completion: nil)
            }
        }
        return true
    }
    
    private func topViewControllerWithRootViewController(rootViewController: UIViewController!) -> UIViewController? {
        if (rootViewController == nil) { return nil }
        if (rootViewController.isKind(of: UITabBarController.self)) {
            return topViewControllerWithRootViewController(rootViewController: (rootViewController as! UITabBarController).selectedViewController)
        } else if (rootViewController.isKind(of: UINavigationController.self)) {
            return topViewControllerWithRootViewController(rootViewController: (rootViewController as! UINavigationController).visibleViewController)
        } else if (rootViewController.presentedViewController != nil) {
            return topViewControllerWithRootViewController(rootViewController: rootViewController.presentedViewController)
        }
        
        
        return rootViewController
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Prana")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

