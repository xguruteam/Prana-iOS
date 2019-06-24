//
//  HistoryViewController.swift
//  Prana
//
//  Created by Guru on 6/23/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class HistoryViewController: SuperViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async {
            let todaySession = self.dataController.fetchDailySessions(date: Date())
            
            print(todaySession)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
