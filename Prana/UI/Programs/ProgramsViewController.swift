//
//  ProgramsViewController.swift
//  Prana
//
//  Created by Guru on 4/18/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit
import ExpandableCell


class ProgramsViewController: UIViewController {

    @IBOutlet weak var tableView: ExpandableTableView!
    @IBOutlet weak var titleView: UIView!
    
    var programType: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.expandableDelegate = self
        tableView.expansionStyle = .single
        tableView.animation = .none
        
        onProgramTypeChange(0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        titleView.roundCorners(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 10.0)
        tableView.open(at: IndexPath(row: 0, section: 0))
    }
    
    func onProgramTypeChange(_ type: Int) {
        programType = type
        tableView.closeAll()
        tableView.reloadData()
        tableView.open(at: IndexPath(row: 0, section: 0))
//        tableView.open(at: T##IndexPath)
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
            if programType == 0 {
                cell1.fourteenContainer.isHidden = false
                cell1.customContainer.isHidden = true
                cell1.dailyButton.isClicked = true
                cell1.customButton.isClicked = false
            }
            else {
                cell1.fourteenContainer.isHidden = true
                cell1.customContainer.isHidden = false
                cell1.dailyButton.isClicked = false
                cell1.customButton.isClicked = true
            }
            return [cell1]
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChildCell")!
            return [cell]
        default:
            break
        }
        return nil
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, heightsForExpandedRowAt indexPath: IndexPath) -> [CGFloat]? {
        switch indexPath.row {
        case 0:
            if programType == 0 {
                return [740]
            }
            else {
                return [995]//[740]
            }
            
        case 1:
            return [33]
            
        default:
            break
        }
        return nil
        
    }
    
    //    func numberOfSections(in tableView: ExpandableTableView) -> Int {
    //        return 1
    //    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, numberOfRowsInSection section: Int) -> Int {
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
        guard let cell = expandableTableView.dequeueReusableCell(withIdentifier: "ProgramParentCell") as? ExpandableCell else { return UITableViewCell() }
        cell.arrowImageView.image = UIImage(named: "ic_arrow_down")
//        cell.arrowImageView.contentMode = .scaleAspectFit
        cell.rightMargin = 56.0
        return cell
    }
    
    func expandableTableView(_ expandableTableView: ExpandableTableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
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
