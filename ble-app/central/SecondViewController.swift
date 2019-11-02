//
//  SecondViewController.swift
//  ble-app
//
//  Created by 山田楓也 on 2019/11/02.
//  Copyright © 2019 Fuuya Yamada. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

class SecondViewController: UIViewController {
    
    var tableView: UITableView!
    var serviceUuids: [String] = []
    var services: [CBService] = []
    var buttonBefore: UIButton!
    var targetPeriperal: CBPeripheral!
    var centralManager: CBCentralManager!
    
    var serviceUUID = CBUUID(string: "0011")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.blue
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        // TableViewの生成( status barの高さ分ずらして表示 ).
        tableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        // Cellの登録.
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        // DataSourceの設定.
        tableView.dataSource = self
        // Delegateを設定.
        tableView.delegate = self
        // Viewに追加する.
        self.view.addSubview(tableView)
    }
    
    override func didMove(toParent parent: UIViewController?) {
        if parent == nil {
            self.centralManager.cancelPeripheralConnection(self.targetPeriperal)
        }
    }
}
extension SecondViewController: CBPeripheralDelegate{
    /// 接続先のPeripheralを設定
    ///
    /// - Parameter target: target description
    func setPeripheral(target: CBPeripheral) {
        self.targetPeriperal = target
    }
    
    /// CentralManagerを設定
    ///
    /// - Parameter manager: manager description
    func setCentralManager(manager: CBCentralManager) {
        self.centralManager = manager
    }
    
    /// Serviceの検索
    func searchService() {
        print("searchService")
        self.targetPeriperal.delegate = self
        self.targetPeriperal.discoverServices(nil)
    }
    
    
    /// Serviceの検索が終わったら呼び出される
    ///
    /// - Parameters:
    ///   - peripheral: peripheral description
    ///   - error: error description
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let e = error {
            print("Error: \(e.localizedDescription)")
            return
        }
        
        print("didDiscoverServices")
        for service in peripheral.services! {
                serviceUuids.append(service.uuid.uuidString)
                services.append(service)
                print("P: \(String(describing: peripheral.name)) - Discovered service S:'\(service.uuid)'")
        }
        
        tableView.reloadData()
    }
    
}
extension SecondViewController: UITableViewDelegate{
    
    /// Cellが選択された際に呼び出される.
    ///
    /// - Parameters:
    ///   - tableView: tableView description
    ///   - indexPath: indexPath description
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("ServiceUuid: \(serviceUuids[indexPath.row])")
        
        performSegue(withIdentifier: "toThird", sender: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toThird" {
            let thirdViewController = segue.destination as! ThirdViewController
            thirdViewController.setPeripheral(target: self.targetPeriperal)
            thirdViewController.setService(service: self.services[sender as! Int])
            thirdViewController.searchCharacteristics()
        }
    }
}
extension SecondViewController: UITableViewDataSource{
    
    /// Cellの総数を返す.
    ///
    /// - Parameters:
    ///   - tableView: tableView description
    ///   - section: section description
    /// - Returns: return value description
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serviceUuids.count
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
        cell.textLabel!.text = "\(serviceUuids[indexPath.row])"
        cell.textLabel!.font = UIFont.systemFont(ofSize: 16)
        // Cellに値を設定(下).
        cell.detailTextLabel!.text = "Service"
        cell.detailTextLabel!.font = UIFont.systemFont(ofSize: 12)
        
        return cell
    }
}
