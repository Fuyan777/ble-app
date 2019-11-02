//
//  ViewController.swift
//  ble-app
//
//  Created by 山田楓也 on 2019/11/02.
//  Copyright © 2019 Fuuya Yamada. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var uuids = Array<UUID>()
    var names = [UUID : String]()
    var peripherals = [UUID : CBPeripheral]()
    var targetPeripheral: CBPeripheral!
    var centralManager: CBCentralManager!
    let button = UIButton()
    var serviceUUID = CBUUID(string: "0011")
    let charactericUUID = CBUUID(string: "0012")

    override func viewDidLoad() {
        super.viewDidLoad()

       // let barHeight = UIApplication.shared.statusBarFrame.size.heigh

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        tableView.dataSource = self
        tableView.delegate = self

        button.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
        button.backgroundColor = UIColor.red
        button.layer.masksToBounds = true
        button.setTitle("検索", for: UIControl.State.normal)
        button.setTitleColor(UIColor.white, for: UIControl.State.normal)
        button.layer.cornerRadius = 20.0
        button.layer.position = CGPoint(x: self.view.frame.width/2, y:self.view.frame.height-50)
        button.tag = 1
        button.addTarget(self, action: #selector(onClickMyButton(sender:)), for: .touchUpInside)
        self.view.addSubview(button)
        
        //UINavigationBar.appearance().
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /// ボタンが押されたときに呼び出される。
    ///
    /// - Parameter sender: sender description
    @objc func onClickMyButton(sender: UIButton){

        // 配列をリセット.
        self.uuids = []
        self.names = [:]
        self.peripherals = [:]

        // CoreBluetoothを初期化および始動.
        centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
    }
}
extension ViewController: UITableViewDataSource{
    /// Cellの総数を返す。
    ///
    /// - Parameters:
    ///   - tableView: tableView description
    ///   - section: section description
    /// - Returns: return value description
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.names.count
    }
}
extension ViewController: UITableViewDelegate{

    /// Cellが選択されたときに呼び出される。
    ///
    /// - Parameters:
    ///   - tableView: tableView description
    ///   - indexPath: indexPath description
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let uuid = self.uuids[indexPath.row]
        print("^^^^^^^^^^^^^^^^^^^^^^^^^^^")
        print("Num: \(indexPath.row)")
        print("uuid: \(uuid.description)")
        print("Name: \(String(describing: self.names[uuid]?.description))")
        print("^^^^^^^^^^^^^^^^^^^^^^^^^^^")

        self.targetPeripheral = self.peripherals[uuid]
        self.centralManager.connect(self.targetPeripheral, options: nil)
    }

    /// Cellに値を設定する。
    ///
    /// - Parameters:
    ///   - tableView: tableView description
    ///   - indexPath: indexPath description
    /// - Returns: return value description
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier:"MyCell" )

        let uuid = self.uuids[indexPath.row]
        // Cellに値を設定.
        cell.textLabel!.sizeToFit()
        cell.textLabel!.textColor = UIColor.red
        cell.textLabel!.text = self.names[uuid]
        cell.textLabel!.font = UIFont.systemFont(ofSize: 20)
        // Cellに値を設定(下).
        cell.detailTextLabel!.text = uuid.description
        cell.detailTextLabel!.font = UIFont.systemFont(ofSize: 12)
        return cell
    }
}
extension ViewController: CBCentralManagerDelegate{

    /// Central Managerの状態がかわったら呼び出される。
    ///
    /// - Parameter central: Central manager
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("state \(central.state)")

        switch central.state {
        case .poweredOff:
            print("Bluetoothの電源がOff")
        case .poweredOn:
            print("Bluetoothの電源はOn")
            // BLEデバイスの検出を開始.
            centralManager.scanForPeripherals(withServices: nil)
            Timer.scheduledTimer(withTimeInterval: 2, repeats: false) {_ in
                print("スキャン停止")
                self.centralManager.stopScan()
            }

        case .resetting:
            print("レスティング状態")
        case .unauthorized:
            print("非認証状態")
        case .unknown:
            print("不明")
        case .unsupported:
            print("非対応")
        @unknown default:
            print("")
        }
    }

    /// PheripheralのScanが成功したら呼び出される。
    ///
    /// - Parameters:
    ///   - central: central description
    ///   - peripheral: peripheral description
    ///   - advertisementData: advertisementData description
    ///   - RSSI: RSSI description
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        print("----------------------")
        print("pheripheral.name: \(String(describing: peripheral.name))")
        print("advertisementData:\(advertisementData)")
        print("RSSI: \(RSSI)")
        print("peripheral.identifier.uuidString: \(peripheral.identifier.uuidString)")
        print("----------------------")
        
        let uuid = UUID(uuid: peripheral.identifier.uuid)
        self.uuids.append(uuid)
        let kCBAdvDataLocalName = advertisementData["kCBAdvDataLocalName"] as? String
        if let name = kCBAdvDataLocalName {
            self.names[uuid] = name.description
        } else {
            self.names[uuid] = "no name"
        }
        self.peripherals[uuid] = peripheral

        tableView.reloadData()
    }

    /// Pheripheralに接続した時に呼ばれる。
    ///
    /// - Parameters:
    ///   - central: central description
    ///   - peripheral: peripheral description
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connect")

        self.performSegue(withIdentifier: "toSec", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSec" {
            let secondViewController = segue.destination as! SecondViewController
            secondViewController.setPeripheral(target: self.targetPeripheral)
            secondViewController.setCentralManager(manager: self.centralManager)
            secondViewController.searchService()
            //secondViewController.modalTransitionStyle = UIModalTransitionStyle.partialCurl
        }
    }

    /// Pheripheralの接続に失敗した時に呼ばれる。
    ///
    /// - Parameters:
    ///   - central: central description
    ///   - peripheral: peripheral description
    ///   - error: error description
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if let e = error {
            print("Error: \(e.localizedDescription)")
            return
        }
        print("not connnect")
    }
}
