//
//  ProgramsViewController.swift
//  Prana
//
//  Created by Guru on 4/18/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit
import ExpandableCell
import MKProgress


class ProgramsViewController: UIViewController {
    
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

    @IBOutlet weak var tableView: ExpandableTableView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleSubLabel: UILabel!
    
    @IBOutlet weak var titleConstrain: NSLayoutConstraint!
    
    var programType: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.expandableDelegate = self
        tableView.expansionStyle = .single
        tableView.animation = .none
        
        titleSubLabel.isHidden = true
        titleConstrain.constant = 0.0
        
        onProgramTypeChange(0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        titleView.roundCorners(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 10.0)
//        tableView.open(at: IndexPath(row: 0, section: 0))
    }
    
    func reloadPage() {
        tableView.closeAll()
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
        tableView.closeAll()
        tableView.reloadData()
        tableView.open(at: IndexPath(row: 0, section: 0))
//        tableView.open(at: T##IndexPath)
    }
    
    func onNotificationTime(_ time: Date) {
        notificationTime = time
    }
    
    func onNotificationEnableChange(_ isEnable: Bool) {
        isNotificationEnable = isEnable
    }
    
    func onTrainingStart() {
        MKProgress.show()
        tableView.closeAll()
        isTrainingStarted = true
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1000)) {
            self.tableView.open(at: IndexPath(row: 1, section: 0))
            MKProgress.hide()
        }
        
        if programType == 0 {
            titleLabel.text = "14 Days Training"
            titleSubLabel.isHidden = false
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM d, yyyy"
            titleSubLabel.text = "Day 1: " + dateFormatter.string(from: Date())
            titleConstrain.constant = -20
        }
        else {
            titleLabel.text = "Custom Training"
            titleSubLabel.isHidden = true
            titleSubLabel.text = ""
            titleConstrain.constant = 0
        }
    }
    
    func onSessionKindChange(_ kind: Int) {
        sessionKind = kind
    }
    
    func onSessionTypeChange(_ type: Int) {
        sessionType = type
    }
    
    func onSessionPositionChange(_ position: Int) {
        self.sessionPosition = position
    }
    
    func onCustomBreathingGoalChange(_ duration: Int) {
        customBreathingGoal = duration
    }
    
    func onCustomPostureGoalChange(_ duration: Int) {
        customPostureGoal = duration
    }
    
    func onSessionDurationChange(_ duration: Int) {
        sessionDuration = duration
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
}

extension ProgramsViewController: ExpandableDelegate {
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, expandedCellsForRowAt indexPath: IndexPath) -> [UITableViewCell]? {
        switch indexPath.row {
        case 0:
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
                cell1.lblCustomDescription.isHidden = true
                if programType == 0 {
                    cell1.startButton.setTitle("CANCEL 14 DAY PROGRAM", for: .normal)
                }
                else {
                    cell1.startButton.setTitle("UPDATE CUSTOM TRAINING", for: .normal)
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
            
            return [cell1]
            
        case 1:
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
            
            cell.changeKind(sessionKind)
            cell.changeType(sessionType)
            cell.changePosition(sessionPosition)
            cell.sessionDuration = sessionDuration
            cell.sessionPattern = sessionPattern
            
            return [cell]
        default:
            break
        }
        return nil
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, heightsForExpandedRowAt indexPath: IndexPath) -> [CGFloat]? {
        switch indexPath.row {
        case 0:
            if isTrainingStarted {
                if programType == 0 {
                    return [740 - 445]
                }
                else {
                    return [995 - 418]//[740]
                }
            }
            else {
                if programType == 0 {
                    return [740]
                }
                else {
                    return [995]//[740]
                }
            }
            
        case 1:
            if programType == 0 {
                return [550]
            }
            return [550+170]
            
        default:
            break
        }
        return nil
        
    }
    
    //    func numberOfSections(in tableView: ExpandableTableView) -> Int {
    //        return 1
    //    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, numberOfRowsInSection section: Int) -> Int {
        if isTrainingStarted {
            return 2
        }
        else {
            return 1
        }
        return 2
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, didSelectRowAt indexPath: IndexPath) {
        //        print("didSelectRow:\(indexPath)")
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, didSelectExpandedRowAt indexPath: IndexPath) {
        //        print("didSelectExpandedRowAt:\(indexPath)")
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, expandedCell: UITableViewCell, didSelectExpandedRowAt indexPath: IndexPath) {
        //        if let cell = expandedCell as? ExpandedCell {
        //            print("\(cell.titleLabel.text ?? "")")
        //        }
    }
    
    //    func expandableTableView(_ expandableTableView: ExpandableTableView, titleForHeaderInSection section: Int) -> String? {
    //        return "Section:\(section)"
    //    }
    //    func expandableTableView(_ expandableTableView: ExpandableTableView, heightForHeaderInSection section: Int) -> CGFloat {
    //        return 20
    //    }
    //
    func expandableTableView(_ expandableTableView: ExpandableTableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        switch indexPath.row {
        case 0:
            guard let cell = expandableTableView.dequeueReusableCell(withIdentifier: "ProgramParentCell") as? ExpandableCell else { return UITableViewCell() }
            cell.arrowImageView.image = UIImage(named: "ic_arrow_down")
            //        cell.arrowImageView.contentMode = .scaleAspectFit
            cell.rightMargin = 56.0
            return cell
        case 1:
            guard let cell = expandableTableView.dequeueReusableCell(withIdentifier: "SessionParentCell") as? ExpandableCell else { return UITableViewCell() }
            cell.arrowImageView.image = UIImage(named: "ic_arrow_down")
            //        cell.arrowImageView.contentMode = .scaleAspectFit
            cell.rightMargin = 56.0
            
            cell.roundCorners(corners: [.layerMinXMinYCorner, .layerMinXMaxYCorner], radius: 10.0)
            return cell
        default:
            break
        }
        
        return UITableViewCell()
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0, 1:
            return 50
        default:
            break
        }
        
        return 44
    }
    
    @objc(expandableTableView:didCloseRowAt:) func expandableTableView(_ expandableTableView: UITableView, didCloseRowAt indexPath: IndexPath) {
        let cell = expandableTableView.cellForRow(at: indexPath)
        cell?.contentView.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)
        cell?.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)
    }
    
    func expandableTableView(_ expandableTableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func expandableTableView(_ expandableTableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        //        let cell = expandableTableView.cellForRow(at: indexPath)
        //        cell?.contentView.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        //        cell?.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
    }
}
