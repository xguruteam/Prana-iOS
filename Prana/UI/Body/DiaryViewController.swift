//
//  DiaryViewController.swift
//  Prana
//
//  Created by Guru on 6/22/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class DiaryViewController: UIViewController {

    @IBOutlet weak var lblDate: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        let now = Date()
        lblDate.text = now.dateString()
    }
    
    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    

}
