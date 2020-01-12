//
//  TestViewController.swift
//  Prana
//
//  Created by Guru on 1/11/20.
//  Copyright © 2020 Prana. All rights reserved.
//

import UIKit

class TestViewController: SuperViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let button = UIButton(type: .system)
        button.setTitle("Close", for: .normal)
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        button.addTarget(self, action: #selector(onClose), for: .touchUpInside)
    }
    
    @objc func onClose() {
        self.dismiss(animated: true, completion: nil)
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
