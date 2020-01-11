//
//  PranaDeviceManager.swift
//  Prana
//
//  Created by Luccas on 3/7/19.
//  Copyright © 2019 Prana. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol PranaDeviceManagerDelegate: class {
    func PranaDeviceManagerDidStartScan()
    func PranaDeviceManagerDidStopScan(with error: String?)
    func PranaDeviceManagerDidDiscover(_ device: PranaDevice)
    func PranaDeviceManagerDidConnect(_ deviceName: String)
    func PranaDeviceManagerDidDisconnect()
    func PranaDeviceManagerDidOpenChannel()
    func PranaDeviceManagerDidReceiveLiveData(_ data: String)
}

extension PranaDeviceManagerDelegate {
    func PranaDeviceManagerDidStartScan() {}
    func PranaDeviceManagerDidStopScan(with error: String?) {}
    func PranaDeviceManagerDidDiscover(_ device: PranaDevice) {}
    func PranaDeviceManagerDidConnect(_ deviceName: String) {}
    func PranaDeviceManagerDidDisconnect() {}
    func PranaDeviceManagerDidOpenChannel() {}
    func PranaDeviceManagerDidReceiveLiveData(_ data: String) {}
}

class PranaDeviceManager: NSObject {
    
    static let RX_SERVICE_UUID = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
    static let RX_CHAR_UUID = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
    static let TX_CHAR_UUID = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"
    
    let concurrentQueue = DispatchQueue(label: "ScanningQueue")
    
    //MARK: Singleton Share PranaDeviceManager
    static let shared = PranaDeviceManager()
    
    var isRunning: Bool = false
    
    let centralManager: CBCentralManager
    
    private var delegates: [PranaDeviceManagerDelegate] = []
    
    var currentDevice: CBPeripheral?
    var isConnected: Bool = false
    
    var rxChar: CBCharacteristic?
    
    var needStopLive = false
    
    override init() {
        
        centralManager = CBCentralManager(delegate: nil, queue: concurrentQueue, options: [CBCentralManagerOptionShowPowerAlertKey: true])
        super.init()
        centralManager.delegate = self
    }
    
    open func prepare() {
        
    }
    
    open func startScan() {
        isRunning = true
        if centralManager.state == .poweredOn {
            start()
            delegates.forEach { $0.PranaDeviceManagerDidStartScan() }
            return
        }
        delegates.forEach { $0.PranaDeviceManagerDidStopScan(with: "Bluetooth is turned off.") }
        return
    }
    
    open func stopScan() {
        if isRunning {
            isRunning = false
            if centralManager.state == .poweredOn {
                stop()
                delegates.forEach { $0.PranaDeviceManagerDidStopScan(with: nil) }
                return
            }
        }
    }
    
    open func startGettingLiveData() {
        guard let char = rxChar else {
            return
        }
        
        needStopLive = false
        buff = nil
        currentDevice?.writeValue("start20hzdata".data(using: .utf8)!, for: char, type: .withoutResponse)
    }
    
    open func sendCommand(_ command: String) {
        guard let char = rxChar else {
            return
        }
        print("prana command " + command)
        currentDevice?.writeValue(command.data(using: .utf8)!, for: char, type: .withoutResponse)
    }
    
    open func stopGettingLiveData() {
        guard let char = rxChar else {
            return
        }
        
        needStopLive = true
        currentDevice?.writeValue("stopData".data(using: .utf8)!, for: char, type: .withoutResponse)
    }
    
    private func start() {
        disconnect()
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }
    
    private func stop() {
        centralManager.stopScan()
    }
    
    open func addDelegate(_ delegate: PranaDeviceManagerDelegate) {
        delegates.append(delegate)
    }
    
    open func removeDelegate(_ delegate: PranaDeviceManagerDelegate) {
        delegates.remove(delegate as! NSObject)
    }
    
    open func connectTo(_ device: CBPeripheral) {
        
        let prevDevice = currentDevice
        currentDevice = device
        
        if isConnected == true {
            centralManager.cancelPeripheralConnection(prevDevice!)
        }
        
        isConnected = true
        
        centralManager.connect(currentDevice!, options: nil)
    }
    
    open func reconnect() {
        if isConnected == true {
            centralManager.cancelPeripheralConnection(currentDevice!)
        }
    }
    
    open func disconnect() {
        if isConnected == true {
            isConnected = false
            centralManager.cancelPeripheralConnection(currentDevice!)
        }
        
        currentDevice = nil
        rxChar = nil
    }
    
    //MARK: Notify to Delegates
    func didConnect() {
        delegates.forEach { $0.PranaDeviceManagerDidConnect(currentDevice?.name ?? "Unknown") }
    }
    
    func didDisconnect() {
        delegates.forEach { $0.PranaDeviceManagerDidDisconnect() }
    }
    
    func didReceiveData(_ parameter: CBCharacteristic) {
        processLiveData(parameter)
    }
    
    var buff: String?
    
    func processLiveData(_ parameter: CBCharacteristic) {
        guard let data  = String(data: parameter.value!, encoding: .utf8) else {
            return
        }
        
        if data.starts(with: "20hz,")
            || data.starts(with: "Upright,")
            || data.starts(with: "EndSessionEarly") {
            if let raw = buff {
                if !needStopLive {
                    
                    delegates.forEach { $0.PranaDeviceManagerDidReceiveLiveData(raw) }
                }
            }
            
            if !data.starts(with: "EndSessionEarly") {
                buff = data
            }
        }
        else {
            if let _ = buff {
                buff = buff! + data
            }
            else {
                buff = data
            }
        }
    }
    
}

extension PranaDeviceManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            if isRunning {
                start()
                delegates.forEach { $0.PranaDeviceManagerDidStartScan() }
            }
        }
        else {
            if isRunning {
                stop()
                delegates.forEach { $0.PranaDeviceManagerDidStopScan(with: "Bluetooth is turned off.") }
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let c2device = PranaDevice(name: peripheral.name ?? "Unknown", rssi: RSSI.doubleValue, id: peripheral.identifier.uuidString, peripheral: peripheral)
        delegates.forEach { $0.PranaDeviceManagerDidDiscover(c2device) }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if isConnected == true {
            if peripheral.isEqual(currentDevice) {
                didConnect()
                peripheral.delegate = self
                peripheral.discoverServices([CBUUID(string: PranaDeviceManager.RX_SERVICE_UUID)])
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if isConnected == true {
            if peripheral.isEqual(currentDevice) {
                isConnected = false
                didDisconnect()
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        // try to re-connect
        if isConnected == true {
            if peripheral.isEqual(currentDevice) {
                isConnected = false
                didDisconnect()
            }
        } else {
            isConnected = false
            didDisconnect()
        }
    }
    
    func tryReconnect() {
        let peripherals = centralManager.retrievePeripherals(withIdentifiers: [currentDevice!.identifier])
        
        if let item = peripherals.first {
            currentDevice = item
            centralManager.connect(currentDevice!, options: nil)
        }
        else {
            isConnected = false
            currentDevice = nil
            didDisconnect()
        }
    }
    
}

extension PranaDeviceManager: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let _ = error {
            return
        }
        
        if let services = peripheral.services {
            for service in services {
                if service.uuid.uuidString == PranaDeviceManager.RX_SERVICE_UUID {
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let _ = error {
            return
        }
        
        if let chars = service.characteristics {
            for char in chars {
                switch char.uuid.uuidString {
                case PranaDeviceManager.TX_CHAR_UUID:
                    peripheral.setNotifyValue(true, for: char)
                case PranaDeviceManager.RX_CHAR_UUID:
                    rxChar = char
                default:
                    continue
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let _ = error {
            return
        }
        
        if characteristic.isNotifying {
            concurrentQueue.asyncAfter(deadline: DispatchTime.now() + .seconds(0)) { [weak self] in
                guard let self = self else { return }
                self.delegates.forEach { $0.PranaDeviceManagerDidOpenChannel() }
            }
        }
        else {
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let _ = error {
            return
        }
        
        didReceiveData(characteristic)
    }

}
