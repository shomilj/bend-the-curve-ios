//
//  HomeTVC.swift
//  Coronavirus
//
//  Created by Shomil Jain on 3/19/20.
//  Copyright © 2020 Pineal Labs. All rights reserved.
//

import UIKit
import Firebase

class HomeTVC: UITableViewController {

    var global = RegionModel()
    var regions = [RegionModel]()
    
    var selectedRegion: RegionModel!

    func loadData() {
        
        Firestore.firestore()
            .collection("statistics")
            .whereField("country", isEqualTo: "Global")
            .addSnapshotListener { (snapshotUW, errorUW) in
                
            guard let snapshot = snapshotUW, let globalData = snapshot.documents.first else {
                return
            }
            
            guard let unwrapped = RegionModel.init(modelData: FirestoreModelData(snapshot: globalData)) else {
                return
            }
                
            self.global = unwrapped
            self.tableView.reloadData()
        }
        
        Firestore.firestore()
            .collection("statistics")
        .order(by: "tenDayNum", descending: true)
        .limit(to: 60)
            .addSnapshotListener { (snapshotUW, errorUW) in
                
                guard let snapshot = snapshotUW else {
                    return
                }
                
                self.regions = []
                for snapshot in snapshot.documents {
                    guard let unwrapped = RegionModel.init(modelData: FirestoreModelData(snapshot: snapshot)) else {
                        continue
                    }
                    self.regions.append(unwrapped)
                }
            
            self.tableView.reloadData()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if Auth.auth().currentUser != nil {
            self.loadData()
        } else {
            Auth.auth().signInAnonymously() { (authResult, error) in
                if error == nil {
                    self.loadData()
                } else {
                    print(error?.localizedDescription)
                    print(error)
                }
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4 + regions.count
    }

}

extension HomeTVC {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        switch indexPath.row {
        case 0:
            return getGraphCell()
        case 1:
            return getNumbersCell()
        case 2:
            return getSeparatorCell()
        case 3:
            return getHeaderCell(header: "Communities")
        default:
            return getTickerCell(index: indexPath.row - 4)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 374
        case 1:
            return 102
        case 2:
            return 14
        case 3:
            return 68
        default:
            return 88
        }
    }
    
    func getGraphCell() -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "GraphCell") as! GraphCell
        cell.update(forRegion: global, selectedGraphView: nil)
        return cell
    }
    
    func getNumbersCell() -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "NumbersCell") as! NumbersCell
        cell.valueOne.text = global.numCases.abbr()
        cell.valueTwo.text = global.numDead.abbr()
        cell.valueThree.text = global.numRecovered.abbr()
        return cell
    }
    
    func getSeparatorCell() -> UITableViewCell {
        return self.tableView.dequeueReusableCell(withIdentifier: "SeparatorCell") as! UITableViewCell
    }
    
    func getHeaderCell(header: String) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "HeaderCell") as! HeaderCell
        cell.headerLabel.text = header
        return cell
    }
    
    func getTickerCell(index: Int) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "TickerCell") as! TickerCell
        cell.update(forRegion: regions[index])
        return cell
    }
        
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row > 3 {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            let selected = regions[indexPath.row - 4]
            selectedRegion = selected
            self.performSegue(withIdentifier: "selectedRegion", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? RegionTVC {
            dest.region = selectedRegion
        }
    }
}
