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
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        tableView.expandableDelegate = self
        tableView.expansionStyle = .multi
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
