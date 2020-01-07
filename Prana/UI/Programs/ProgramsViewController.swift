//
//  ProgramsViewController.swift
//  Prana
//
//  Created by Luccas on 4/18/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit
import MKProgress
import CoreBluetooth
import Toaster

class ProgramsViewController: UIViewController {
    
    var dataController: DataController?
    
    var isTrainingStarted = false
    var sessionKind: Int = 0
    var sessionType: Int = 0
    var sessionPosition: Int = 0
    var notificationTime: Date = Date(calendar: Calendar.current, timeZone: TimeZone.current, era: 0, year: 2019, month: 4, day: 26, hour: 8, minute: 0, second: 0, nanosecond: 0)
    var isNotificationEnable = true
    var customBreathingGoal: Int = 5
    var customPostureGoal: Int = 5
    var sessionDuration: Int = 5
    var sessionPattern: Int = 0

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleSubLabel: UILabel!
    
    @IBOutlet weak var titleConstrain: NSLayoutConstraint!
    @IBOutlet weak var bluetoothView: BluetoothStateView!
    
    var programType: Int = 0
    
    
    var isProgramCellOpen = true
    var isSessionCellOpen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        NotificationCenter.default.addObserver(self, selector: #selector(onConnectViewControllerNextToSession), name: .connectViewControllerDidNextToSession, object: nil)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        dataController = appDelegate.dataController
        
        
        let dayNumber = dataController?.currentDay ?? 0
        if let currentProgram = dataController?.currentProgram, dayNumber > 14 {
            if currentProgram.type == .fourteen {
                let alert = UIAlertController(style: .alert, title: "14 day Program", message: "Congratulation! You have completed the 14 day training program.")
                alert.addAction(title: "Ok", style: .cancel)
                alert.show()
                currentProgram.endedAt = Date()
                currentProgram.status = "completed"
                dataController?.endProgram(currentProgram)
            }
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(onLandscapeViewControllerDismiss), name: .landscapeViewControllerDidDismiss, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDeviceOrientationChange), name: .deviceOrientationDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onVisualViewControllerEnd), name: .visualViewControllerEndSession, object: nil)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        if let currentProgram = dataController?.currentProgram {
            programType = currentProgram.type == .fourteen ? 0 : 1
            
            isTrainingStarted = true
            isProgramCellOpen = false
            isSessionCellOpen = false
            //            tableView.reloadData()
            
            if let time = dataController?.dailyNotification {
                notificationTime = time
                isNotificationEnable = true
            }
            else {
//                notificationTime = Date()
                isNotificationEnable = false
            }
            
            if programType == 0 {
                let dayNumber = dataController?.currentDay ?? 0
                let (_, _, wearing) = fourteenGoals[dayNumber]
                sessionPosition = wearing
            }
            
            if programType == 0 {
//                titleLabel.text = "14 Days Training"
                setTitle("14 Days Training")
                titleSubLabel.isHidden = false
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMMM d, yyyy"
                titleSubLabel.text = "Day \((dataController?.currentDay ?? 0) + 1): " + dateFormatter.string(from: Date())
                titleConstrain.constant = -20
            }
            else {
//                titleLabel.text = "Custom Training"
                setTitle("Custom Training")
                titleSubLabel.isHidden = true
                titleSubLabel.text = ""
                titleConstrain.constant = 0
                
                customBreathingGoal = dataController?.breathingGoals ?? 5
                customPostureGoal = dataController?.postureGoals ?? 5
            }
        }
        else {
            titleSubLabel.isHidden = true
            titleConstrain.constant = 0.0
            
            setTitle("Training")
            
            onProgramTypeChange(0)
            
            appDelegate.notifications.requestAllowNotification()
            isNotificationEnable = true
        }
        
        let savedProgramType = dataController?.programType ?? 100
        if savedProgramType > 1 {
            titleSubLabel.isHidden = true
            titleConstrain.constant = 0.0
            
            onProgramTypeChange(0)
        }
        else {
            
        }
        
        if let sessionSettings = dataController?.sessionSettings {
            sessionKind = sessionSettings.kind
            sessionType = sessionSettings.type
            sessionDuration = sessionSettings.duration
            sessionPosition = sessionSettings.wearing
        }
        

    }
    
    func setTitle(_ title: String) {
        if let titleFont = UIFont(name: "Quicksand-Bold", size: 24.0)  {
            let shadow : NSShadow = NSShadow()
            shadow.shadowOffset = CGSize(width: 0, height: 2)
            shadow.shadowColor = UIColor(hexString: "#910c5274")
            shadow.shadowBlurRadius = 4
            
            let attributes = [
                NSAttributedString.Key.font : titleFont,
                NSAttributedString.Key.foregroundColor : UIColor.white,
                NSAttributedString.Key.shadow : shadow] as [NSAttributedString.Key : Any]
            
            var titleStr = NSAttributedString(string: title, attributes: attributes) //1
            
            titleLabel.attributedText = titleStr //3
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
      
        
        PranaDeviceManager.shared.addDelegate(self)
        
        bluetoothView.isEnabled = PranaDeviceManager.shared.isConnected
        
//        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        PranaDeviceManager.shared.removeDelegate(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
      
        titleView.roundCorners(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 10.0)
//        tableView.open(at: IndexPath(row: 0, section: 0))
    }
    
//    override var shouldAutorotate: Bool {
//        return true
//    }
    
    @objc func onLandscapeViewControllerDismiss() {
//        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
    }
    
    @objc func onVisualViewControllerEnd() {
//        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
      
        if let lastSession = dataController?.lastSession as? TrainingSession {
            let storyboard = UIStoryboard(name: "History", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "SessionDetailViewController") as! SessionDetailViewController
            vc.type = .session
            vc.session = lastSession
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: {
                self.present(vc, animated: true, completion: nil)
            })
        }
    }
    
    @objc func onDeviceOrientationChange() {
        self.setNeedsStatusBarAppearanceUpdate()
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
    }
    
    func reloadPage() {
//        tableView.closeAll()
        tableView.reloadData()
//        if isTrainingStarted {
//            tableView.open(at: IndexPath(row: 1, section: 0))
//        }
//        else {
//            tableView.open(at: IndexPath(row: 0, section: 0))
//        }
    }
    
    func onProgramTypeChange(_ type: Int) {
        programType = type
//        tableView.closeAll()
//        tableView.beginUpdates()
        tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .fade)
//        tableView.endUpdates()
//        tableView.reloadData()
//        tableView.open(at: IndexPath(row: 0, section: 0))
//        tableView.open(at: T##IndexPath)
    }
    
    func onNotificationTime(_ time: Date) {
        notificationTime = time
        if !isTrainingStarted {
            return
        }
        
        if !isNotificationEnable {
            return
        }
        
        // reschedule notifications
        scheduleNotifications()
    }
    
    func onNotificationEnableChange(_ isEnable: Bool) {
        isNotificationEnable = isEnable
        
        if !isTrainingStarted {
            return
        }
        
        if isNotificationEnable {
            // schedule notifications
            scheduleNotifications()
        }
        else {
            // remove notifications
            removeNotifications()
        }
    }
    
    func removeNotifications() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let center = appDelegate.notifications
        
        center.removeNotifications(identifiers: ["ptrn0", "ptrn1", "ptrn2", "ptrn3", "ptrn4"])
        dataController?.dailyNotification = nil
        dataController?.saveSettings()
    }
    
    func scheduleNotifications() {
        removeNotifications()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let center = appDelegate.notifications
        
        let title = "Prana Reminder"
        let body = "Do a quick training session to help meet your breathing and posture goals today."
        
        center.scheduleDailyNotification(title: title, body: body, date: notificationTime, identifier: "ptrn0")
        
        let calendar = Calendar.current
        
        for i in 1...3 {
            let nextTime = Date(timeInterval: 3600 * 4 * Double(i), since: notificationTime)
            let components = calendar.dateComponents([.day], from: notificationTime, to: nextTime)
            if components.day > 0 { break }
            center.scheduleDailyNotification(title: title, body: body, date: nextTime, identifier: "ptrn\(i)")
        }
        
        dataController?.dailyNotification = notificationTime
        dataController?.saveSettings()
    }
    
    func cancelTraining() {
        MKProgress.show()
        isTrainingStarted = false
        isProgramCellOpen = true
        isSessionCellOpen = false
        
        
        sessionKind = 0
        sessionType = 0
        sessionDuration = 5
        sessionPosition = 0
        
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1000)) {
            //            self.tableView.closeAll()
            //            self.tableView.open(at: IndexPath(row: 1, section: 0))
            MKProgress.hide()
        }
        
        titleSubLabel.isHidden = true
        titleConstrain.constant = 0.0
        setTitle("Training")
        titleSubLabel.isHidden = true
        titleSubLabel.text = ""
        titleConstrain.constant = 0
        
        onProgramTypeChange(0)
        
        if let currentProgram = dataController?.currentProgram {
            currentProgram.endedAt = Date()
            currentProgram.status = "canceled"
            dataController?.endProgram(currentProgram)
        }
        dataController?.programType = 100
        dataController?.breathingGoals = 0
        dataController?.postureGoals = 0
        dataController?.dailyNotification = nil
        
        dataController?.sessionSettings = SessionSettings()
        
        dataController?.saveSettings()
        
        removeNotifications()
    }
    
    func onTrainingStart() {
        if isTrainingStarted {
            // cancel
            if programType == 0 {
                let alert = UIAlertController(style: .alert, title: "Are you sure you wish to cancel your 14 day training program?", message: "You will not lose history data, but will lose the sequence in the program.")
                alert.addAction(title: "Yes", style: .destructive) { action in
                    self.cancelTraining()
                }
                alert.addAction(title: "No", style: .cancel)
                alert.show()
                return
            }
            
            self.cancelTraining()

            return
        }
        
        dataController?.sessionSettings = SessionSettings()
        
        MKProgress.show()
        isTrainingStarted = true
        isProgramCellOpen = false
        isSessionCellOpen = true
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1000)) {
//            self.tableView.closeAll()
//            self.tableView.open(at: IndexPath(row: 1, section: 0))
            MKProgress.hide()
        }
        
        let program = Program(type: programType == 0 ? .fourteen : .custom)
        dataController?.startProgram(program)
        
        dataController?.programType = programType
        if isNotificationEnable {
//            dataController?.dailyNotification = notificationTime
            scheduleNotifications()
        }
        else {
            dataController?.dailyNotification = nil
        }
        
        if programType == 0 {
//            titleLabel.text = "14 Days Training"
            setTitle("14 Days Training")
            titleSubLabel.isHidden = false
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM d, yyyy"
            titleSubLabel.text = "Day 1: " + dateFormatter.string(from: Date())
            titleConstrain.constant = -20
            
            dataController?.breathingGoals = 5
            dataController?.postureGoals = 5
        }
        else {
//            titleLabel.text = "Custom Training"
            setTitle("Custom Training")
            titleSubLabel.isHidden = true
            titleSubLabel.text = ""
            titleConstrain.constant = 0
            
            dataController?.breathingGoals = customBreathingGoal
            dataController?.postureGoals = customPostureGoal
        }
        
        dataController?.saveSettings()
    }
    
    func onSessionStart() {
        
        if PranaDeviceManager.shared.isConnected {
            startSession()
            return
        }
        
//        let alert = UIAlertController(style: .alert, message: "Press and hold the button on Prana for at least 2 seconds to wirelessly connect to the app. Then wear the device as indicated.")
//        alert.addAction(title: "Ok", style: .default) { action in
//            self.gotoChargingGuide()
//        }
//        alert.addAction(title: "Cancel", style: .cancel)
//        alert.show()
        
        self.gotoConnectViewController()
    }
    
    func gotoChargingGuide() {
        let firstVC = Utils.getStoryboardWithIdentifier(identifier: "ChargingGuideViewController") as! ChargingGuideViewController
        firstVC.isTutorial = false
        let navVC = UINavigationController(rootViewController: firstVC)
        self.present(navVC, animated: true, completion: nil)
    }
    
    func gotoConnectViewController() {
        let firstVC = Utils.getStoryboardWithIdentifier(identifier: "ConnectViewController") as! ConnectViewController
        firstVC.isTutorial = false
        firstVC.completionHandler = { [unowned self] in
            self.startSession()
        }
        let navVC = UINavigationController(rootViewController: firstVC)
        self.present(navVC, animated: true, completion: nil)
    }
    
    @objc func onConnectViewControllerNextToSession() {
        startSession()
    }
        
    func startSession() {
            
        Log("Program: \(programType == 0 ? "14 day" : "Custom")")
        Log("Notification: \(notificationTime)")
        if programType == 1 {
            Log("Daily Breathing goal: \(customBreathingGoal) Minutes")
            Log("Daily Posture goal: \(customPostureGoal) Minutes")
        }
        
        switch sessionKind {
        case 0:
            Log("Session Kind: Breathing with Posture")
        case 1:
            Log("Session Kind: Breathing only")
        case 2:
            Log("Session Kind: Posture only")
        default:
            break
        }
        
        Log("Session Type: \(sessionType == 0 ? "Visual" : "Buzzer")")
        
        Log("Session Duration: \(sessionDuration) Minutes")
        
        if programType == 1 {
            Log("Session Pattern: Focus")
            Log("Session Position: \(sessionPosition)")
        }
        
        var newSessionSettings = SessionSettings()
        newSessionSettings.kind = sessionKind
        newSessionSettings.type = sessionType
        newSessionSettings.duration = sessionDuration
        newSessionSettings.wearing = sessionPosition
        
        let prevLastWearing = dataController?.sessionSettings?.lastWearing ?? 0
        let prevWearing = dataController?.sessionSettings?.wearing ?? 0
        
        if sessionPosition == 2{
            if prevWearing == 2 {
                if prevLastWearing == 0 {
                    newSessionSettings.lastWearing = 1
                }
                else {
                    newSessionSettings.lastWearing = 0
                }
            }
            else {
                newSessionSettings.lastWearing = 0
            }
        }
        else {
            newSessionSettings.lastWearing = sessionPosition
        }
        
        dataController?.sessionSettings = newSessionSettings
        dataController?.saveSettings()

        if sessionType == 1 {
            var viewController: BaseBuzzerTrainingViewController?
            if sessionKind == 0 {
                viewController = Utils.getStoryboardWithIdentifier(name:"BuzzerTraining", identifier: "BuzzerTrainingViewController") as? BuzzerTrainingViewController
            } else if sessionKind == 1 {
                viewController = Utils.getStoryboardWithIdentifier(name:"BuzzerTraining", identifier: "BuzzerBreathingOnlyTrainingViewController") as! BuzzerBreathingOnlyTrainingViewController
            } else {
                viewController = Utils.getStoryboardWithIdentifier(name:"BuzzerTraining", identifier: "BuzzerPostureOnlyTrainingViewController") as! BuzzerPostureOnlyTrainingViewController
            }
            
            if let vc = viewController {
                vc.isTutorial = false
                vc.sessionWearing = newSessionSettings.lastWearing
                vc.sessionDuration = sessionDuration
                vc.sessionKind = sessionKind
                
                if programType == 0 {
                    vc.whichPattern = 0
                    vc.subPattern = 5
                    vc.maxSubPattern = 34
                    vc.patternTitle = patternNames[0].0
                }
                else {
                    if let savedPattern = dataController?.btPattern {
                        if savedPattern.type == 16 {
                            if savedPattern.sub == 0 {
                                vc.whichPattern = 0
                                vc.subPattern = savedPattern.startResp
                                vc.startSubPattern = savedPattern.startResp
                                vc.maxSubPattern = savedPattern.minResp
                                vc.patternTitle = patternNames[savedPattern.type].0
                            }
                            else {
                                Pattern.patternSequence[16][0] = [savedPattern.inhalationTime, savedPattern.retentionTime, savedPattern.exhalationTime, savedPattern.timeBetweenBreaths, "Custom"]
                                vc.whichPattern = 16
                                vc.subPattern = 0
                                vc.maxSubPattern = 34
                                vc.patternTitle = patternNames[savedPattern.type].0
                            }
                        }
                        else {
                            vc.whichPattern = patternNumbers[savedPattern.type]
                            if vc.whichPattern == 0 {
                                vc.subPattern = 5
                                vc.maxSubPattern = 34
                                vc.patternTitle = patternNames[savedPattern.type].0
                            }
                            else {
                                vc.subPattern = 0
                                vc.maxSubPattern = 34
                                vc.patternTitle = patternNames[savedPattern.type].0
                            }
                        }
                    }
                    else {
                        fatalError()
                    }
                }
                
                self.present(vc, animated: true) {
                    
                }
            }

        }
        else {
            if sessionKind == 2 {
                
            }
            else {              
                let vc = Utils.getStoryboardWithIdentifier(name: "VisualTraining", identifier: "VisualTrainingViewController") as! VisualTrainingViewController
                vc.isTutorial = false
                vc.sessionKind = sessionKind
                vc.sessionDuration = sessionDuration
                vc.sessionWearing = newSessionSettings.lastWearing
                if programType == 0 {
                    vc.whichPattern = 0
                    vc.subPattern = 0
                    vc.skipCalibration = 0
                    vc.startSubPattern = 0
                    vc.maxSubPattern = 34
                    vc.patternTitle = patternNames[0].0
                }
                else {
                    if let savedPattern = dataController?.vtPattern {
                        if savedPattern.type == 16 {
                            if savedPattern.sub == 0 {
                                vc.whichPattern = 0
                                vc.subPattern = 0
                                vc.skipCalibration = 1
                                vc.startSubPattern = savedPattern.startResp
                                vc.maxSubPattern = savedPattern.minResp
                            }
                            else {
                                Pattern.patternSequence[16][0] = [savedPattern.inhalationTime, savedPattern.retentionTime, savedPattern.exhalationTime, savedPattern.timeBetweenBreaths, "Custom"]
                                vc.whichPattern = 16
                                vc.subPattern = 0
                                vc.skipCalibration = 1
                                vc.startSubPattern = 0
                                vc.maxSubPattern = 34
                            }
                        }
                        else {
                            vc.whichPattern = patternNumbers[savedPattern.type]
                            if vc.whichPattern == 0 {
                                vc.skipCalibration = 0
                                vc.subPattern = 0
                                vc.startSubPattern = 0
                                vc.maxSubPattern = 34
                            }
                            else {
                                vc.skipCalibration = 1
                                vc.subPattern = 0
                                vc.startSubPattern = 0
                                vc.maxSubPattern = 34
                            }
                        }
                        vc.patternTitle = patternNames[savedPattern.type].0
                    }
                    else {
                        fatalError()
                    }
                }
                self.present(vc, as: .landscape, curtainColor: .white)
            }
        }
        
        if sessionPosition == 2 {
            onSessionPositionChange(sessionPosition)
        }
    }
    
    func onSessionKindChange(_ kind: Int) {
        sessionKind = kind
        saveSessionSettings()
    }
    
    func onSessionTypeChange(_ type: Int) {
        sessionType = type
        saveSessionSettings()
    }
    
    func onSessionPositionChange(_ position: Int) {
        self.sessionPosition = position
        saveSessionSettings()
        let row = isProgramCellOpen ? 4 : 3
//        tableView.reloadData()
//        tableView.beginUpdates()
        tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .fade)
//        tableView.endUpdates()
    }
    
    func saveSessionSettings() {
        var newSessionSettings = SessionSettings()
        newSessionSettings.kind = sessionKind
        newSessionSettings.type = sessionType
        newSessionSettings.duration = sessionDuration
        newSessionSettings.wearing = sessionPosition
        
        let prevLastWearing = dataController?.sessionSettings?.lastWearing ?? 0
        let prevWearing = dataController?.sessionSettings?.wearing ?? 0
        
        if sessionPosition == 2{
            if prevWearing == 2 {
                newSessionSettings.lastWearing = prevLastWearing            }
            else {
                newSessionSettings.lastWearing = 1
            }
        }
        else {
            newSessionSettings.lastWearing = prevLastWearing
        }
        
        dataController?.sessionSettings = newSessionSettings
        dataController?.saveSettings()
    }
    
    func onCustomBreathingGoalChange(_ duration: Int) {
        customBreathingGoal = duration
        dataController?.breathingGoals = customBreathingGoal
        dataController?.saveSettings()
    }
    
    func onCustomPostureGoalChange(_ duration: Int) {
        customPostureGoal = duration
        dataController?.postureGoals = customPostureGoal
        dataController?.saveSettings()
    }
    
    func onSessionDurationChange(_ duration: Int) {
        sessionDuration = duration
        saveSessionSettings()
    }
    
    func onSessionPatternChange(_ pattern: Int) {
        sessionPattern = pattern
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func onBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getCellForType(_ type: Int) -> UITableViewCell? {
        switch type {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProgramParentCell") as? ProgramParentCell else { return UITableViewCell() }
            cell.arrowImageView.image = UIImage(named: "ic_arrow_down")
            //        cell.arrowImageView.contentMode = .scaleAspectFit
            if isProgramCellOpen {
                cell.arrowImageView.image = UIImage(cgImage: cell.arrowImageView.image!.cgImage!, scale: 1.0, orientation: .downMirrored)
            }
            return cell
        case 1:
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "ProgramChildCell") as! ProgramChildCell
            
            cell1.notificationContainer.roundCorners(corners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 10.0)
            
            cell1.programTypeListner = { [weak self] (type) in
                guard let self = self else { return }
                self.onProgramTypeChange(type)
            }
            cell1.startTrainingListner = { [weak self] in
                guard let self = self else { return }
                self.onTrainingStart()
            }
            cell1.notificationTimeListener = { [weak self] (time) in
                guard let self = self else { return }
                self.onNotificationTime(time)
            }
            cell1.notificationEnableChangeListener = { [weak self] (isEnable) in
                guard let self = self else { return }
                self.onNotificationEnableChange(isEnable)
            }
            cell1.customBreathingGoalChangeListener = { [weak self] (goal) in
                guard let self = self else { return }
                self.onCustomBreathingGoalChange(goal)
            }
            cell1.customPostureGoalChangeListener = { [weak self] (goal) in
                guard let self = self else { return }
                self.onCustomPostureGoalChange(goal)
            }
            
            if programType == 0 {
                cell1.fourteenContainer.isHidden = false
                cell1.customContainer.isHidden = true
                cell1.goalsContainer.isHidden = true
                cell1.dailyButton.isClicked = true
                cell1.customButton.isClicked = false
                //                cell1.startButton.setTitle("START 14 DAY PROGRAM", for: .normal)
            }
            else {
                cell1.fourteenContainer.isHidden = true
                cell1.customContainer.isHidden = false
                cell1.goalsContainer.isHidden = false
                cell1.dailyButton.isClicked = false
                cell1.customButton.isClicked = true
                //                cell1.startButton.setTitle("START CUSTOM TRAINING", for: .normal)
            }
            
            if isTrainingStarted {
                cell1.programContainer.isHidden = true
                cell1.fourteenContainer.isHidden = true
                cell1.customContainer.isHidden = true
                if programType == 0 {
                    cell1.startButton.setTitle("CANCEL 14 DAY PROGRAM", for: .normal)
                }
                else {
                    cell1.startButton.setTitle("CANCEL CUSTOM TRAINING", for: .normal)
                }
            }
            else {
                cell1.programContainer.isHidden = false
                cell1.fourteenContainer.isHidden = false
                cell1.lblCustomDescription.isHidden = false
                if programType == 0 {
                    cell1.startButton.setTitle("START 14 DAY PROGRAM", for: .normal)
                }
                else {
                    cell1.startButton.setTitle("START CUSTOM TRAINING", for: .normal)
                }
            }
            
            cell1.notificationTime = self.notificationTime
            cell1.swNotification.isOn = isNotificationEnable
            cell1.customBreathingGoal = self.customBreathingGoal
            cell1.customPostureGoal = self.customPostureGoal
            
            return cell1
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SessionParentCell") as? SessionParentCell else { return UITableViewCell() }
            cell.arrowImageView.image = UIImage(named: "ic_arrow_down")
            //        cell.arrowImageView.contentMode = .scaleAspectFit
            if isSessionCellOpen {
                cell.arrowImageView.image = UIImage(cgImage: cell.arrowImageView.image!.cgImage!, scale: 1.0, orientation: .downMirrored)
            }
            cell.roundCorners(corners: [.layerMinXMinYCorner, .layerMinXMaxYCorner], radius: 10.0)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SessionChildCell") as! SessionChildCell
            cell.settingContainer.roundCorners(corners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 10.0)
            
            if programType == 0 {
                cell.constrain1.constant = 30
                cell.constrain2.constant = 40
            }
            else {
                cell.constrain1.constant = 200
                cell.constrain2.constant = 20
            }
            
            cell.kindChangeListener = { [weak self] (kind) in
                guard let self = self else { return }
                self.onSessionKindChange(kind)
            }
            
            cell.typeChangeListener = { [weak self] (type) in
                guard let self = self else { return }
                self.onSessionTypeChange(type)
            }
            
            cell.positionChangeListener = { [weak self] (position) in
                guard let self = self else { return }
                self.onSessionPositionChange(position)
            }
            cell.sessionDurationChangeListener = { [weak self] (duration) in
                self?.onSessionDurationChange(duration)
            }
            
            cell.sessionPatternChangeListener = { [weak self] (pattern) in
                self?.onSessionPatternChange(pattern)
            }
            
//            cell.sessionStartListener = { [weak self] in
//                self?.onSessionStart()
//            }
//
            cell.changeKind(sessionKind)
            cell.changeType(sessionType)
            cell.changePosition(sessionPosition)
            cell.sessionDuration = sessionDuration
//            cell.sessionPattern = sessionPattern
            
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SessionStartStopCell") as! SessionStartStopCell
            cell.sessionStartListener = { [weak self] in
                self?.onSessionStart()
            }
            
            if sessionPosition == 2 {
                let lastWearing = dataController?.sessionSettings?.lastWearing ?? 0
                if lastWearing == 0 {
                    cell.changePosition(1)
                }
                else {
                    cell.changePosition(0)
                }
            }
            else {
                cell.changePosition(sessionPosition)
            }
            
            return cell
        default:
            break
        }
        
        return nil
    }
    
    func getHeightForType(_ type: Int) -> CGFloat {
        switch type {
        case 0: // ProgramParentCell
            return 50
        case 1:
            if isTrainingStarted {
                if programType == 0 {
                    return 740 - 445
                }
                else {
                    return 1000 - 425
                }
            }
            else {
                if programType == 0 {
                    return 740
                }
                else {
                    return 1000
                }
            }
        case 2:
            return 50
        case 3:
            if programType == 0 {
                return 550 - 200
            }
            return 550+170 - 200
        case 4:
            return 200
        default:
            break
        }
        
        return 0.0
    }
        
}

extension ProgramsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            return getCellForType(0)!
        case 1:
            if isProgramCellOpen {
                return getCellForType(1)!
            }
            else {
                return getCellForType(2)!
            }
        case 2:
            if isProgramCellOpen {
                return getCellForType(2)!
            }
            else {
                if isSessionCellOpen {
                    return getCellForType(3)!
                }
                else {
                    return getCellForType(4)!
                }
            }
        case 3:
            if isProgramCellOpen {
                if isSessionCellOpen {
                    return getCellForType(3)!
                }
                else {
                    return getCellForType(4)!
                }
            }
            else {
                return getCellForType(4)!
            }

        case 4:
            return getCellForType(4)!
        default:
            break
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return getHeightForType(0)
        case 1:
            if isProgramCellOpen {
                return getHeightForType(1)
            }
            else {
                return getHeightForType(2)
            }
        case 2:
            if isProgramCellOpen {
                return getHeightForType(2)
            }
            else {
                if isSessionCellOpen {
                    return getHeightForType(3)
                }
                else {
                    return getHeightForType(4)
                }
            }
        case 3:
            if isProgramCellOpen {
                if isSessionCellOpen {
                    return getHeightForType(3)
                }
                else {
                    return getHeightForType(4)
                }
            }
            else {
                return getHeightForType(4)
            }
        case 4:
            return getHeightForType(4)
        default:
            break
        }
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView(tableView, heightForRowAt: indexPath)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if isTrainingStarted {
            count = 3
        }
        else {
            count = 1
        }
        
        if isProgramCellOpen {
            count += 1
        }
        
        if isSessionCellOpen {
            count += 1
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            if isProgramCellOpen {
                isProgramCellOpen = false
                tableView.beginUpdates()
                tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                tableView.deleteRows(at: [IndexPath(row: 1, section: 0)], with: .fade)
                tableView.endUpdates()
            }
            else {
                isProgramCellOpen = true
                tableView.beginUpdates()
                tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .fade)
                tableView.endUpdates()
            }
        case 1:
            if isProgramCellOpen == false {
                if isSessionCellOpen {
                    isSessionCellOpen = false
                    tableView.beginUpdates()
                    tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
                    tableView.deleteRows(at: [IndexPath(row: 2, section: 0)], with: .fade)
                    tableView.endUpdates()
                }
                else {
                    isSessionCellOpen = true
                    tableView.beginUpdates()
                    tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
                    tableView.insertRows(at: [IndexPath(row: 2, section: 0)], with: .fade)
                    tableView.endUpdates()
                }
            }
            break
        case 2:
            if isProgramCellOpen {
                if isSessionCellOpen {
                    isSessionCellOpen = false
                    tableView.beginUpdates()
                    tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
                    tableView.deleteRows(at: [IndexPath(row: 3, section: 0)], with: .fade)
                    tableView.endUpdates()
                }
                else {
                    isSessionCellOpen = true
                    tableView.beginUpdates()
                    tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
                    tableView.insertRows(at: [IndexPath(row: 3, section: 0)], with: .fade)
                    tableView.endUpdates()
                }
            }
            break
        case 3:
            break
        default:
            break
        }
    }
}

extension ProgramsViewController: PranaDeviceManagerDelegate {
    func PranaDeviceManagerDidConnect(_ deviceName: String) {
        DispatchQueue.main.async {
            self.bluetoothView.isEnabled = true
        }
    }
    
    func PranaDeviceManagerDidDisconnect() {
        DispatchQueue.main.async {
            self.bluetoothView.isEnabled = false
            let toast  = Toast(text: "Prana is disconnected.", duration: Delay.short)
            ToastView.appearance().backgroundColor = UIColor(hexString: "#995ad598")
            ToastView.appearance().textColor = .white
            ToastView.appearance().font = UIFont(name: "Quicksand-Medium", size: 14)
            toast.show()
        }
    }
    
}
