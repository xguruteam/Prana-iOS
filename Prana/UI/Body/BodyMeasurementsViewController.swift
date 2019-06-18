//
//  BodyMeasurementsViewController.swift
//  Prana
//
//  Created by Guru on 6/18/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit

enum BMSteps {
    case ready
    case select
    case take
}

enum BMPosition: String {
    case neck = "NECK"
}

class BodyMeasurementsViewController: UIViewController {

    @IBOutlet weak var bodyContainer: UIView!
    @IBOutlet weak var batteryStatus: BluetoothStateView!
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var btnTake: UIButton!
    
    let buttons: [BMPosition: BMButton] = [
        .neck: BMButton(position: BMPosition.neck.rawValue)
    ]
    
    var position: BMPosition? {
        didSet {
            if let oldValue = oldValue {
                let oldButton = buttons[oldValue]
                oldButton?.isSelected = false
            }
            
            guard let position = position else { return }
            
            let newButton = buttons[position]
            newButton?.isSelected = true
        }
    }
    
    var step: BMSteps = .ready {
        didSet {
            switch step {
            case .ready:
                btnStart.isHidden = false
                btnTake.isHidden = true
            case .select:
                btnStart.isHidden = true
                btnTake.isHidden = false
            default:
                break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let buttonWidth: CGFloat = 42.0
        let buttonHeight: CGFloat = 20.0
        
        let button = buttons[.neck]!
        bodyContainer.addSubview(button)
        button.addTarget(self, action: #selector(onButtonClick(_:)), for: .touchUpInside)
        
        button.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        button.centerXAnchor.constraint(equalTo: bodyContainer.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: bodyContainer.topAnchor, constant: 62.0).isActive = true
        
        
        reset()
        
    }
    
    func reset() {
        self.position = nil
//        unselectAllButtons()
        step = .ready
    }
    
    func unselectAllButtons() {
        buttons.forEach { (key, value) in
            value.isSelected = false
        }
    }
    
    @objc func onButtonClick(_ sender: BMButton) {
        guard step == .select else { return }
        
        let title = sender.position
        self.position = BMPosition(rawValue: title)
    }
    
    @IBAction func onStart(_ sender: Any) {
        guard step == .ready else { return }
        
        step = .select
    }
    
    @IBAction func onTake(_ sender: Any) {
        guard let position = position else {
            let alert = UIAlertController(title: nil, message: "Please select Position.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        step = .take
        
        let button = buttons[position]
        button?.value = 10.0
    }
    
    @IBAction func onHelp(_ sender: Any) {
    }
    
    @IBAction func onReset(_ sender: Any) {
        reset()
    }
    
    @IBAction func onEdit(_ sender: Any) {
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
