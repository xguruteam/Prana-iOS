//
//  HistoryViewController.swift
//  Prana
//
//  Created by Luccas on 2/28/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD
import MKProgress

class HistoryViewController2: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tbl_history: UITableView!
    
    @IBOutlet weak var lblValues: UILabel!
    
    
    var sessionData: [[String: Any]]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = false
        } else {
            // Fallback on earlier versions
        }
        self.title = "History"
        // Do any additional setup after loading the view.
        
        getSessions()
    }
    
    
    func getSessions() {
        self.sessionData = []
//        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
//        hud.mode = .indeterminate
//        hud.label.text = "Loading..."
        MKProgress.show()
        
        let userdefaults = UserDefaults.standard
        let token = userdefaults.string(forKey: KEY_TOKEN)
        
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(token!)"
        ]
        
        APIClient.sessionManager.request(APIClient.BaseURL + "trainsessions", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: 200..<300)
            .responseJSON {(response) in
                switch response.result {
                case .success:
                    
                    if let data = response.value as? [String: Any] {
                        self.sessionData = data["data"] as? [[String: Any]]
                        self.tbl_history.reloadData()
                        self.lblValues.text = data["summary"] as! String
                    }
                    
                    break
                case .failure:
                    let alertController = UIAlertController(title: "Error", message:
                        "Sync session failed", preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default,handler: nil))
                    self.present(alertController, animated: false, completion: nil)
                    break
                }
//                MBProgressHUD.hide(for: self.view, animated: true)
                MKProgress.hide()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sessionData.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "descriptionCellId") as! SesseionRecordCell
        cell.lblDateTime.text = convertTimeStamp(self.sessionData[indexPath.row]["session_started_at"] as! String, format: "h:mm a")
        cell.tvDescription.text = (self.sessionData[indexPath.row]["description"] as! String)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    

    @IBAction func onBackClick(_ sender: Any) {    self.navigationController?.popViewController(animated: true)
    }
    
    func convertTimeStamp(_ input: String, format: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd HH':'mm':'ss"
        let date = dateFormatter.date(from: input)
        
        let targetDateFormatter = DateFormatter()
        targetDateFormatter.dateFormat = format
//        targetDateFormatter.amSymbol = "AM"
//        targetDateFormatter.pmSymbol = "PM"
        targetDateFormatter.locale = Locale(identifier: "en_GB")
        return targetDateFormatter.string(from: date!)
    }
    
}
