//
//  DevicesViewController.swift
//  Prana
//
//  Created by Luccas on 3/7/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import UIKit
import CoreBluetooth

class DevicesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PranaDeviceManagerDelegate {
    @IBOutlet weak var rightBarButtonItem: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleView: UIView!
    
    var isRemoveing: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PranaDeviceManager.shared.disconnect()
        PranaDeviceManager.shared.addDelegate(self)
        
        self.status = false
        
        // Do any additional setup after loading the view.
        isRemoveing = false
        startScanning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isRemoveing == true {
            return
        }
        
        stopScanning()
        PranaDeviceManager.shared.removeDelegate(self)
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func onBack(_ sender: Any) {
        isRemoveing = true
        stopScanning()
        PranaDeviceManager.shared.removeDelegate(self)
        self.navigationController?.popViewController(animated: true)
    }
    
    var devices = [PranaDevice]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var status = false {
        didSet {
            var title = "Start"
            if status == true {
                title = "Stop"
            }
//            self.rightBarButtonItem.setTitle(title, for: .normal)
        }
    }
    
    @IBAction func toggleScanStop(_ sender: Any) {
        if self.status == false {
            startScanning()
        }
        else {
            stopScanning()
        }
    }
    
    func startScanning() {
        self.devices = [PranaDevice]()
        PranaDeviceManager.shared.delegate = self
        PranaDeviceManager.shared.startScan()
    }
    
    func stopScanning() {
        PranaDeviceManager.shared.stopScan()
        PranaDeviceManager.shared.delegate = nil
        self.status = false
    }
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCell", for: indexPath) as! UITableViewCell
        
        //        if cell == nil {
        //            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "reuseIdentifier")
        //        }
        
        cell.textLabel?.text = self.devices[indexPath.row].name
        //        cell.detailLabel.text = self.devices[indexPath.row].id
        
        let txPower: Double = -62
        var meter: Double = 0
        let rssi: Double = self.devices[indexPath.row].rssi
        if rssi == 0 {
            meter = 0
        }
        let ratio = rssi * 1.0 / txPower
        if ratio < 1.0 {
            meter = pow(ratio, 10)
        }
        else {
            meter = 0.89976 * pow(ratio, 7.7095) + 0.111
        }
        
        cell.detailTextLabel?.text = "\(NSNumber(value: meter))m away"
        
        cell.tag = indexPath.row
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedDevice = self.devices[indexPath.row]
        stopScanning()
        //        C2ConnectionManager.shared.connectTo(selectedDevice)
        PranaDeviceManager.shared.connectTo(selectedDevice.peripheral)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    func PranaDeviceManagerDidStartScan() {
        self.status = true
    }
    
    func PranaDeviceManagerDidStopScan(with error: String?) {
        self.status = false
        PranaDeviceManager.shared.delegate = nil
    }
    
    func PranaDeviceManagerDidDiscover(_ device: PranaDevice) {
        self.devices.append(device)
        self.devices.sort {
            $0.rssi > $1.rssi
        }
    }
    
    func PranaDeviceManagerDidConnect(_ deviceName: String) {
        let alert = UIAlertController(title: "ClubRow", message: "\(deviceName) is connected successfully!", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action: UIAlertAction!) in
            //            C2ConnectionManager.shared.removeDelegate(self)
            //            self.navigationController?.popViewController(animated: true)
            self.onBack(self)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func PranaDeviceManagerFailConnect() {
        let alert = UIAlertController(title: "ClubRow", message: "This device is unable to connect.\n Please try another device!", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func PranaDeviceManagerDidReceiveData(_ parameter: CBCharacteristic) {
    }
}
