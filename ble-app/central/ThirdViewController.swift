//
//  ThirdViewController.swift
//  ble-app
//
//  Created by 山田楓也 on 2019/11/02.
//  Copyright © 2019 Fuuya Yamada. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

class ThirdViewController: UIViewController {
    
    var tableView: UITableView!
    var readTableView: UITableView!
    var services: [CBService] = []
    var characteristics: [CBCharacteristic] = []
    var buttonBefore: UIButton!
    var targetPeriperal: CBPeripheral!
    var targetService: CBService!
    var centralManager: CBCentralManager!
    var targetCharacteristic: CBCharacteristic!
    var readButton: UIButton!
    var notifyLabel: UILabel!
    var writeField: UITextField!
    var writeButton: UIButton!
    var readValues: [Data] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blue
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        tableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        tableView.dataSource = self
        tableView.delegate = self
        self.view.addSubview(tableView)
        
        readTableView = UITableView(frame: CGRect(x: 0, y: barHeight + displayHeight/2 + 100, width: displayWidth, height: 200))
        readTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        readTableView.dataSource = self
        readTableView.delegate = self
        self.view.addSubview(readTableView)
        
        // Readボタン.
        readButton = UIButton()
        readButton.frame = CGRect(x: displayWidth/2 - 150, y: displayHeight/2+50, width: 100, height: 40)
        readButton.backgroundColor = UIColor.red
        readButton.layer.masksToBounds = true
        readButton.setTitle("Read", for: UIControl.State.normal)
        readButton.layer.cornerRadius = 10.0
        readButton.tag = 1
        readButton.addTarget(self, action: #selector(onClickMyButton(sender:)), for: .touchUpInside)
        
        // Norifyボタン.
        notifyLabel = UILabel(frame: CGRect(x:displayWidth/2 + 50, y: displayHeight/2+55, width: 100, height: 30))
        notifyLabel.textColor = UIColor.blue
        notifyLabel.text = "Notify"
        notifyLabel.tag = 2
        notifyLabel.isUserInteractionEnabled = true
        
        // UITextField.
        writeField = UITextField(frame: CGRect(x:10, y: displayHeight/2+15, width: displayWidth - 100 - 30, height: 30))
        writeField.text = ""
        writeField.delegate = self
        writeField.borderStyle = .roundedRect
        writeField.clearButtonMode = .whileEditing
        
        // Writeボタン.
        writeButton = UIButton()
        writeButton.frame = CGRect(x: displayWidth - 110, y: displayHeight/2+10, width: 100, height: 40)
        writeButton.backgroundColor = UIColor.blue
        writeButton.layer.masksToBounds = true
        writeButton.setTitle("Write", for: UIControl.State.normal)
        writeButton.layer.cornerRadius = 10.0
        writeButton.tag = 2
        writeButton.addTarget(self, action: #selector(onClickMyButton(sender:)), for: .touchUpInside)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: UITouch in touches {
            let tag = touch.view!.tag
            if (tag == 2) {
                if !self.targetCharacteristic.isNotifying {
                    self.targetPeriperal.setNotifyValue(true, for: self.targetCharacteristic)
                    notifyLabel.text = "Stop Notify"
                } else {
                    self.targetPeriperal.setNotifyValue(false, for: self.targetCharacteristic)
                    notifyLabel.text = "Notify"
                }
            }
        }
    }
    
    @objc func onClickMyButton(sender: UIButton){
        print("onClickMyButton:")
        print("sender.currentTitile: \(String(describing: sender.currentTitle))")
        print("sender.tag:\(sender.tag)")

        if let charasteristic = self.targetCharacteristic {
            if(sender.tag == 1){
                self.targetPeriperal.readValue(for: charasteristic)
            }
            else if(sender.tag == 2){
                let data = writeField.text!.data(using: String.Encoding.utf8, allowLossyConversion:true)
                self.targetPeriperal.writeValue(data!, for: targetCharacteristic, type: CBCharacteristicWriteType.withResponse)
            }
        }
    }
    
    /// 各種パーツの追加と削除
    ///
    /// - Parameter characteristic: characteristic description
    func addButton(characteristic: CBCharacteristic) {
        // Read
        if (self.readButton.isDescendant(of: self.view)) {
            self.readButton.removeFromSuperview()
        }
        if isRead(characteristic: characteristic) {
            self.view.addSubview(self.readButton)
        }
        // Write
        if (self.writeField.isDescendant(of: self.view)) {
            self.writeField.removeFromSuperview()
        }
        if isWrite(characteristic: characteristic) {
            self.view.addSubview(self.writeField)
        }
        if (self.writeButton.isDescendant(of: self.view)) {
            self.writeButton.removeFromSuperview()
        }
        if isWrite(characteristic: characteristic) {
            self.view.addSubview(self.writeButton)
        }
        // Notify
        if (self.notifyLabel.isDescendant(of: self.view)) {
            self.notifyLabel.removeFromSuperview()
        }
        if isNotify(characteristic: characteristic) {
            if !self.targetCharacteristic.isNotifying {
                notifyLabel.text = "Notify"
            } else {
                notifyLabel.text = "Stop Notify"
            }
            self.view.addSubview(self.notifyLabel)
        }
    }
}

extension ThirdViewController: UITextFieldDelegate{
    /// 改行ボタンが押された時の処理
    ///
    /// - Parameter textField: textField description
    /// - Returns: return value description
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 改行ボタンが押されたらKeyboardを閉じる処理.
        textField.resignFirstResponder()
        return true
    }
}

extension ThirdViewController: UITableViewDelegate{
    
    /// Cellが選択された際に呼び出される.
    ///
    /// - Parameters:
    ///   - tableView: tableView description
    ///   - indexPath: indexPath description
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("characteristics: \(characteristics[indexPath.row])")
        if tableView.isEqual(self.tableView) {
            self.targetCharacteristic = characteristics[indexPath.row]
            addButton(characteristic: self.targetCharacteristic)
        }
    }
}
extension ThirdViewController: UITableViewDataSource{
    
    /// Cellの総数を返す.
    ///
    /// - Parameters:
    ///   - tableView: tableView description
    ///   - section: section description
    /// - Returns: return value description
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.isEqual(self.tableView) {
            return characteristics.count
        } else if tableView.isEqual(self.readTableView) {
            return readValues.count
        }
        return 0
    }
    
    /// Cellに値を設定する.
        ///
        /// - Parameters:
        ///   - tableView: tableView description
        ///   - indexPath: indexPath description
        /// - Returns: return value description
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier:"MyCell" )
            // Cellに値を設定.
            cell.textLabel!.sizeToFit()
            cell.textLabel!.textColor = UIColor.red
            cell.textLabel!.font = UIFont.systemFont(ofSize: 16)
            cell.detailTextLabel!.font = UIFont.systemFont(ofSize: 12)

            if tableView.isEqual(self.tableView) {
                let characteristic = characteristics[indexPath.row]
                cell.textLabel!.text = "\(characteristic.uuid)"
                var strProp = ""
                if isRead(characteristic: characteristic) {
                    strProp += "Read!"
                }
                if isWrite(characteristic: characteristic) {
                    strProp += "Write!"
                }
                if isNotify(characteristic: characteristic) {
                    strProp += "Notifiy!"
                }
                cell.detailTextLabel!.text = "\(strProp)"
            }
            else if tableView.isEqual(self.readTableView) {
                let value = self.readValues[indexPath.row]
                
                let str : String = String.init(data: value, encoding: .utf8)!
                let num : Int = Int(str)!
                
                cell.textLabel!.text = "id: \(String(num))"
                let now = Date()
                let locale = Locale(identifier: "ja_JP")
                cell.detailTextLabel!.text = "\(now.description(with: locale))"
            }

            return cell
        }
    }
extension ThirdViewController: CBPeripheralDelegate{
    /// CharastaristicがReadされると呼び出される
    ///
    /// - Parameters:
    ///   - peripheral: peripheral description
    ///   - characteristic: characteristic description
    ///   - error: error description
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let e = error {
            print("Error: \(e.localizedDescription)")
            return
        }
        readValues.insert(characteristic.value!, at: 0)
        if readValues.count > 10 {
            readValues.removeLast()
        }
        readTableView.reloadData()
    }
    
    /// 接続先のPeripheralを設定
    ///
    /// - Parameter target: target description
    func setPeripheral(target: CBPeripheral) {
        self.targetPeriperal = target
    }
    
    /// Description
    ///
    /// - Parameter service: service description
    func setService(service: CBService) {
        self.targetService = service
    }
    
    /// Characteristicの検索
    func searchCharacteristics(){
        print("searchService")
        self.targetPeriperal.delegate = self
        self.targetPeriperal.discoverCharacteristics(nil, for: self.targetService)
    }
    
    /// Characteristicの検索が終わったら呼び出される
    ///
    /// - Parameters:
    ///   - peripheral: peripheral description
    ///   - service: service description
    ///   - error: error description
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        print("didDiscoverCharacteristicsForService")
        
        for characteristic in service.characteristics! {
            characteristics.append(characteristic)
        }
        tableView.reloadData()
    }
    
    /// Read可能か
    ///
    /// - Parameter characteristic: characteristic description
    /// - Returns: return value description
    func isRead(characteristic: CBCharacteristic) -> Bool{
        if characteristic.properties.contains(.read) {
            return true
        }
        return false
    }
    
    /// Write可能か
    ///
    /// - Parameter characteristic: characteristic description
    /// - Returns: return value description
    func isWrite(characteristic: CBCharacteristic) -> Bool{
        if characteristic.properties.contains(.write) || characteristic.properties.contains(.writeWithoutResponse) {
            return true
        }
        return false
    }
    
    /// Notifyに対応しているか
    ///
    /// - Parameter characteristic: characteristic description
    /// - Returns: return value description
    func isNotify(characteristic: CBCharacteristic) -> Bool{
        if characteristic.properties.contains(.notify) {
            return true
        }
        return false
    }
}
