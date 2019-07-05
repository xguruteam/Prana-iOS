//
//  SettingsViewController.swift
//  Prana
//
//  Created by Guru on 7/4/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit
import Toaster

class SettingsViewController: SuperViewController {

    let backgroundView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "app-background")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .red
        return tableView
    }()
    
    let container: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Account & Help"
        label.font = UIFont(name: "Quicksand-Medium", size: 15)
        label.textColor = UIColor(hexString: "#415165")
        return label
    }()
    
    let bluetoothStateView: BluetoothStateView = {
        let imageView = BluetoothStateView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let roundedContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.roundCorners(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 10)
        view.backgroundColor = .white
        return view
    }()
    
    let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let subView = UIImageView()
        view.addSubview(subView)
        subView.translatesAutoresizingMaskIntoConstraints = false
        subView.image = UIImage(named: "banner-nature")
        subView.contentMode = .scaleToFill
        subView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        subView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        subView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        subView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        return view
    }()
    
    static let makeLargeButton: ((String) -> UIButton) = { (title) -> UIButton in
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor(hexString: "#79859f"), for: .normal)
        button.titleLabel?.font = UIFont(name: "Quicksand-Medium", size: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentHorizontalAlignment = .left
        return button
    }
    
    static let makeSmallButton: ((String) -> UIButton) = { (title) -> UIButton in
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor(hexString: "#79859f"), for: .normal)
        button.titleLabel?.font = UIFont(name: "Quicksand-Regular", size: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentHorizontalAlignment = .left
        return button
    }
    
    let bSetting: UIButton = makeLargeButton("Settings")
    let bEdit: UIButton = makeSmallButton("Edit Profile Info")
    let bDisconnect = makeSmallButton("Disconnect Now")
    let bAutoDisconnect = makeSmallButton("Automatically Disconnect")
    let bLogout = makeSmallButton("Log out")
    
    let bAbout = makeLargeButton("About Us")
    let bPrivacy = makeSmallButton("Privacy Policy")
    let bTerm = makeSmallButton("Terms of Use")
    let bApp = makeSmallButton("App & Firmware Versions")
    
    let bTutorials = makeLargeButton("Tutorials")
    let bTutorial1 = makeSmallButton("Tutorial 1")
    let bTutorial2 = makeSmallButton("Tutorial 2")
    let bTutorial3 = makeSmallButton("Tutorial 3")
    
    let bFaq = makeLargeButton("FAQ")
    
    let bContact = makeLargeButton("Contact Us")
    
    let sAutoDisconnect: UISwitch = {
        let uiSwitch = UISwitch()
        uiSwitch.tintColor = UIColor(hexString: "#2bb7b8")
        uiSwitch.onTintColor = UIColor(hexString: "#2bb7b8")
        uiSwitch.translatesAutoresizingMaskIntoConstraints = false
        return uiSwitch
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(backgroundView)
        backgroundView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        backgroundView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.backgroundColor = .clear

        tableView.tableHeaderView = container
        container.bounds.size.height = 605
        
        container.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        
        container.addSubview(bluetoothStateView)
        bluetoothStateView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
        bluetoothStateView.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -20).isActive = true
        bluetoothStateView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        bluetoothStateView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        container.addSubview(roundedContainer)
        roundedContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16).isActive = true
        roundedContainer.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 20).isActive = true
        roundedContainer.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -20).isActive = true
        roundedContainer.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20).isActive = true

        roundedContainer.addSubview(headerView)
        headerView.topAnchor.constraint(equalTo: roundedContainer.topAnchor, constant: 0).isActive = true
        headerView.leftAnchor.constraint(equalTo: roundedContainer.leftAnchor, constant: 0).isActive = true
        headerView.rightAnchor.constraint(equalTo: roundedContainer.rightAnchor, constant: 0).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: 88).isActive = true
        
        let largeButtonInset: CGFloat = 16
        let smallButtonInset: CGFloat = 16
        
        let buttonSpacing: CGFloat = 7
        let insets = UIEdgeInsets(top: 6, left: smallButtonInset, bottom: 6, right: 6)
        
        // Settings
        roundedContainer.addSubview(bSetting)
        bSetting.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: buttonSpacing).isActive = true
        bSetting.leftAnchor.constraint(equalTo: roundedContainer.leftAnchor, constant: largeButtonInset).isActive = true
        bSetting.rightAnchor.constraint(equalTo: roundedContainer.rightAnchor, constant: 0 - largeButtonInset).isActive = true
        
        roundedContainer.addSubview(bEdit)
        bEdit.topAnchor.constraint(equalTo: bSetting.bottomAnchor, constant: 10).isActive = true
        bEdit.leftAnchor.constraint(equalTo: roundedContainer.leftAnchor, constant: largeButtonInset).isActive = true
        bEdit.rightAnchor.constraint(equalTo: roundedContainer.rightAnchor, constant: 0 - largeButtonInset).isActive = true
        bEdit.contentEdgeInsets = insets
        
        roundedContainer.addSubview(bDisconnect)
        bDisconnect.topAnchor.constraint(equalTo: bEdit.bottomAnchor, constant: buttonSpacing).isActive = true
        bDisconnect.leftAnchor.constraint(equalTo: roundedContainer.leftAnchor, constant: largeButtonInset).isActive = true
        bDisconnect.rightAnchor.constraint(equalTo: roundedContainer.rightAnchor, constant: 0 - largeButtonInset).isActive = true
        bDisconnect.contentEdgeInsets = insets
        
        roundedContainer.addSubview(bAutoDisconnect)
        roundedContainer.addSubview(sAutoDisconnect)
        bAutoDisconnect.topAnchor.constraint(equalTo: bDisconnect.bottomAnchor, constant: buttonSpacing).isActive = true
        bAutoDisconnect.leftAnchor.constraint(equalTo: roundedContainer.leftAnchor, constant: largeButtonInset).isActive = true
        bAutoDisconnect.rightAnchor.constraint(equalTo: sAutoDisconnect.leftAnchor, constant: 0 - largeButtonInset).isActive = true
        bAutoDisconnect.contentEdgeInsets = insets
        
        sAutoDisconnect.rightAnchor.constraint(equalTo: roundedContainer.rightAnchor, constant: 0 - largeButtonInset).isActive = true
        sAutoDisconnect.centerYAnchor.constraint(equalTo: bAutoDisconnect.centerYAnchor).isActive = true

        roundedContainer.addSubview(bLogout)
        bLogout.topAnchor.constraint(equalTo: bAutoDisconnect.bottomAnchor, constant: buttonSpacing).isActive = true
        bLogout.leftAnchor.constraint(equalTo: roundedContainer.leftAnchor, constant: largeButtonInset).isActive = true
        bLogout.rightAnchor.constraint(equalTo: roundedContainer.rightAnchor, constant: 0 - largeButtonInset).isActive = true
        bLogout.contentEdgeInsets = insets

        // About
        roundedContainer.addSubview(bAbout)
        bAbout.topAnchor.constraint(equalTo: bLogout.bottomAnchor, constant: buttonSpacing).isActive = true
        bAbout.leftAnchor.constraint(equalTo: roundedContainer.leftAnchor, constant: largeButtonInset).isActive = true
        bAbout.rightAnchor.constraint(equalTo: roundedContainer.rightAnchor, constant: 0 - largeButtonInset).isActive = true
        
        
        roundedContainer.addSubview(bPrivacy)
        bPrivacy.topAnchor.constraint(equalTo: bAbout.bottomAnchor, constant: buttonSpacing).isActive = true
        bPrivacy.leftAnchor.constraint(equalTo: roundedContainer.leftAnchor, constant: largeButtonInset).isActive = true
        bPrivacy.rightAnchor.constraint(equalTo: roundedContainer.rightAnchor, constant: 0 - largeButtonInset).isActive = true
        bPrivacy.contentEdgeInsets = insets
        
        roundedContainer.addSubview(bTerm)
        bTerm.topAnchor.constraint(equalTo: bPrivacy.bottomAnchor, constant: buttonSpacing).isActive = true
        bTerm.leftAnchor.constraint(equalTo: roundedContainer.leftAnchor, constant: largeButtonInset).isActive = true
        bTerm.rightAnchor.constraint(equalTo: roundedContainer.rightAnchor, constant: 0 - largeButtonInset).isActive = true
        bTerm.contentEdgeInsets = insets
        
        roundedContainer.addSubview(bApp)
        bApp.topAnchor.constraint(equalTo: bTerm.bottomAnchor, constant: buttonSpacing).isActive = true
        bApp.leftAnchor.constraint(equalTo: roundedContainer.leftAnchor, constant: largeButtonInset).isActive = true
        bApp.rightAnchor.constraint(equalTo: roundedContainer.rightAnchor, constant: 0 - largeButtonInset).isActive = true
        bApp.contentEdgeInsets = insets
        
        
        // Tutorials
//        roundedContainer.addSubview(bTutorials)
//        bTutorials.topAnchor.constraint(equalTo: bApp.bottomAnchor, constant: buttonSpacing).isActive = true
//        bTutorials.leftAnchor.constraint(equalTo: roundedContainer.leftAnchor, constant: largeButtonInset).isActive = true
//        bTutorials.rightAnchor.constraint(equalTo: roundedContainer.rightAnchor, constant: 0 - largeButtonInset).isActive = true
//
//        roundedContainer.addSubview(bTutorial1)
//        bTutorial1.topAnchor.constraint(equalTo: bTutorials.bottomAnchor, constant: buttonSpacing).isActive = true
//        bTutorial1.leftAnchor.constraint(equalTo: roundedContainer.leftAnchor, constant: largeButtonInset).isActive = true
//        bTutorial1.rightAnchor.constraint(equalTo: roundedContainer.rightAnchor, constant: 0 - largeButtonInset).isActive = true
//        bTutorial1.contentEdgeInsets = insets
//
//        roundedContainer.addSubview(bTutorial2)
//        bTutorial2.topAnchor.constraint(equalTo: bTutorial1.bottomAnchor, constant: buttonSpacing).isActive = true
//        bTutorial2.leftAnchor.constraint(equalTo: roundedContainer.leftAnchor, constant: largeButtonInset).isActive = true
//        bTutorial2.rightAnchor.constraint(equalTo: roundedContainer.rightAnchor, constant: 0 - largeButtonInset).isActive = true
//        bTutorial2.contentEdgeInsets = insets
//
//        roundedContainer.addSubview(bTutorial3)
//        bTutorial3.topAnchor.constraint(equalTo: bTutorial2.bottomAnchor, constant: buttonSpacing).isActive = true
//        bTutorial3.leftAnchor.constraint(equalTo: roundedContainer.leftAnchor, constant: largeButtonInset).isActive = true
//        bTutorial3.rightAnchor.constraint(equalTo: roundedContainer.rightAnchor, constant: 0 - largeButtonInset).isActive = true
//        bTutorial3.contentEdgeInsets = insets
        
        // FAQ
        roundedContainer.addSubview(bFaq)
        bFaq.topAnchor.constraint(equalTo: bApp.bottomAnchor, constant: buttonSpacing).isActive = true
        bFaq.leftAnchor.constraint(equalTo: roundedContainer.leftAnchor, constant: largeButtonInset).isActive = true
        bFaq.rightAnchor.constraint(equalTo: roundedContainer.rightAnchor, constant: 0 - largeButtonInset).isActive = true
        
        // Contact Us
        roundedContainer.addSubview(bContact)
        bContact.topAnchor.constraint(equalTo: bFaq.bottomAnchor, constant: buttonSpacing).isActive = true
        bContact.leftAnchor.constraint(equalTo: roundedContainer.leftAnchor, constant: largeButtonInset).isActive = true
        bContact.rightAnchor.constraint(equalTo: roundedContainer.rightAnchor, constant: 0 - largeButtonInset).isActive = true
        
        bLogout.addTarget(self, action: #selector(onLogout), for: .touchUpInside)
        bEdit.addTarget(self, action: #selector(onEditProfile), for: .touchUpInside)
        sAutoDisconnect.isOn = dataController.isAutoDisconnect
        sAutoDisconnect.addTarget(self, action: #selector(onChangeAutoDisconnect(_:)), for: .valueChanged)
        bDisconnect.addTarget(self, action: #selector(onDisconnect), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        PranaDeviceManager.shared.addDelegate(self)
        bluetoothStateView.isEnabled = PranaDeviceManager.shared.isConnected
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        PranaDeviceManager.shared.removeDelegate(self)
    }
    
    @objc func onLogout() {
        let alert = UIAlertController(style: .alert, title: "Warning", message: "All settings will be lost!")
        alert.addAction(title: "Cancel", style: .cancel) { (_) in
            
        }
        
        alert.addAction(title: "Ok", style: .destructive) { [unowned self] (_) in
            UserDefaults.standard.removeObject(forKey: KEY_TOKEN)
            UserDefaults.standard.removeObject(forKey: KEY_EXPIREAT)
            UserDefaults.standard.removeObject(forKey: KEY_REMEMBERME)
            UserDefaults.standard.synchronize()
            
            self.dataController.currentUser = nil
            self.dataController.saveUserData()
            
            if PranaDeviceManager.shared.isConnected {
                PranaDeviceManager.shared.stopGettingLiveData()
                PranaDeviceManager.shared.disconnect()
                PranaDeviceManager.shared.delegate = nil
            }
            
            self.dismiss(animated: true, completion: nil)
        }
        alert.show()
        
    }
    
    @objc func onEditProfile() {
        let vc = getViewController(storyboard: "Main", identifier: "SignupViewController") as! SignupViewController
        vc.isUpdateProfile = true
        self.show(vc, sender: self)
    }
    
    @objc func onChangeAutoDisconnect(_ sender: UISwitch) {
        dataController.isAutoDisconnect = sender.isOn
        dataController.saveSettings()
    }
    
    @objc func onDisconnect() {
        if PranaDeviceManager.shared.isConnected {
            PranaDeviceManager.shared.stopGettingLiveData()
            PranaDeviceManager.shared.disconnect()
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

extension SettingsViewController: PranaDeviceManagerDelegate {
    func PranaDeviceManagerDidConnect(_ deviceName: String) {
        DispatchQueue.main.async {
            self.bluetoothStateView.isEnabled = true
        }
    }
    
    func PranaDeviceManagerFailConnect() {
        DispatchQueue.main.async {
            self.bluetoothStateView.isEnabled = false
            let toast  = Toast(text: "Prana is disconnected.", duration: Delay.short)
            ToastView.appearance().backgroundColor = UIColor(hexString: "#995ad598")
            ToastView.appearance().textColor = .white
            ToastView.appearance().font = UIFont(name: "Quicksand-Medium", size: 14)
            toast.show()
        }
    }
}
