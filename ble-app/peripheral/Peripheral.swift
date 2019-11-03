//
//  Peripheral.swift
//  ble-app
//
//  Created by 山田楓也 on 2019/11/02.
//  Copyright © 2019 Fuuya Yamada. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

class Peripheral: UIViewController, CBPeripheralManagerDelegate{
    var peripheralManager: CBPeripheralManager!
    var characteristic: CBMutableCharacteristic!
    
    var sendData: Data = Data()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        let intNum : Int = 1234
        let str : String = String(intNum)
        sendData = str.data(using: .utf8)!
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("periState\(peripheral.state)")
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if error != nil {
            print("***Advertising ERROR")
            return
        }
        print("Advertising success")
    }
    
    func publishservice(){
        let serviceUUID = CBUUID(string: "0011")
        let service = CBMutableService(type: serviceUUID, primary: true)
        let charactericUUID = CBUUID(string: "0012")
        self.characteristic = CBMutableCharacteristic(type: charactericUUID, properties: CBCharacteristicProperties.read, value: nil, permissions: CBAttributePermissions.readable)
        
        service.characteristics = [characteristic]
        self.peripheralManager.add(service)
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if error != nil {
            print("Service Add Failed...")
            return
        }
        print("Service Add Success!")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        if request.characteristic.uuid.isEqual(characteristic.uuid) {
            // CBMutableCharacteristicのvalueをCBATTRequestのvalueにセット
            let data: Data = sendData
            print("data: \(String(describing: data))")
            self.characteristic.value = sendData
            request.value = self.characteristic.value
            // リクエストに応答
            peripheralManager.respond(to: request, withResult: .success)
        }
    }
    
    @IBAction func startAdvertise(_ sender: UIButton) {
        let advertisementData = [CBAdvertisementDataLocalNameKey: "Test Device"]
        publishservice()
        peripheralManager.startAdvertising(advertisementData)
    }
    
    @IBAction func stopAdvertise(_ sender: UIButton) {
        print("stop")
        peripheralManager.stopAdvertising()
    }
    
}
