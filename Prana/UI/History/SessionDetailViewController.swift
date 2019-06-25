//
//  SessionDetailViewController.swift
//  Prana
//
//  Created by Guru on 6/24/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

class SessionDetailViewController: SuperViewController {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "History"
        label.font = UIFont(name: "Quicksand-Medium", size: 15)
        label.textColor = UIColor(hexString: "#45494d")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Breathing & Posture\nSession Details"
        label.font = UIFont(name: "Quicksand-Medium", size: 15)
        label.textColor = UIColor(hexString: "#45494d")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    let backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "ic-back"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    @objc func onBack() {
        self.navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(titleLabel)
        if #available(iOS 11.0, *) {
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        } else {
            titleLabel.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 10).isActive = true
        }
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(subTitleLabel)
        subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0).isActive = true
        subTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        view.addSubview(backButton)
        backButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
        backButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        backButton.addTarget(self, action: #selector(onBack), for: .touchUpInside)
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
