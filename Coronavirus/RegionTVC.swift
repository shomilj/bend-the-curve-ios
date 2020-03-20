//
//  RegionTVC.swift
//  Coronavirus
//
//  Created by Shomil Jain on 3/20/20.
//  Copyright © 2020 Pineal Labs. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import Kingfisher

class RegionTVC: UITableViewController {

    lazy var functions = Functions.functions()

    var region = RegionModel()
    var news = [NewsModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateNews()
        loadNews()
    }
    
    func updateNews() {
        print("Calling function!")
        var keywords = region.region ?? "nan"
        if keywords == "nan" {
            keywords = region.country
        }
        keywords += " Coronavirus"
        print(keywords)
        print(region.documentID)
        functions.httpsCallable("update_news").call(["key": region.documentID!, "keywords": keywords]) { (result, error) in
            print("Finished calling function!")
          if let error = error as NSError? {
            if error.domain == FunctionsErrorDomain {
              let code = FunctionsErrorCode(rawValue: error.code)
              let message = error.localizedDescription
              let details = error.userInfo[FunctionsErrorDetailsKey]
                print("Cancelled erorr!")
                print(code?.rawValue)
                print(message)
                print(details)
            }
          }
        }
    }
    
    func loadNews() {
        
        
        
        Firestore.firestore()
        .collection("news")
            .whereField("key", isEqualTo: region.documentID)
        .order(by: "time", descending: true)
        .limit(to: 60)
            .addSnapshotListener { (snapshotUW, errorUW) in

                guard let snapshot = snapshotUW else {
                    return
                }
                
                self.news = []
                for snapshot in snapshot.documents {
                    guard let unwrapped = NewsModel.init(modelData: FirestoreModelData(snapshot: snapshot)) else {
                        continue
                    }
                    self.news.append(unwrapped)
                }
            
            self.tableView.reloadData()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4 + news.count
    }

}

extension RegionTVC {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        switch indexPath.row {
        case 0:
            return getGraphCell()
        case 1:
            return getSummaryCell()
        case 2:
            return getSeparatorCell()
        case 3:
            return getHeaderCell(header: "News")
        default:
            return getNewsCell(index: indexPath.row - 4)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 374
        case 1:
            return 154
        case 2:
            return 14
        case 3:
            return 68
        default:
            return 126
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row > 3 {
            let article = news[indexPath.row - 4]
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            openLink(withURL: URL(string: article.url), showReader: true)
        }
    }
    
    func getGraphCell() -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "GraphCell") as! GraphCell
        var title = region.region
        if title == "nan" {
            title = region.country
        }
        cell.update(forRegion: region, selectedGraphView: "Confirmed", overrideTitle: title)
        return cell
    }
    
    func getSummaryCell() -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "SummaryCell") as! SummaryCell
        cell.update(forRegion: region)
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
    
    func getNewsCell(index: Int) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "NewsCell") as! NewsCell
        cell.publisherLabel.text = news[index].publisher
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = dateFormatter.date(from: String(news[index].time.prefix(19)))
        
        cell.hourLabel.text = date!.timeAgoSinceDate()
        cell.titleLabel.text = news[index].title
        if let link = news[index].image, let url = URL(string: link) {
            cell.newsImage.kf.setImage(with: url)
        } else {
            cell.newsImage.isHidden = true
        }
        return cell
    }
    
}


extension Date {

    func timeAgoSinceDate() -> String {

        // From Time
        let fromDate = self

        // To Time
        let toDate = Date()

        // Estimation
        // Year
        if let interval = Calendar.current.dateComponents([.year], from: fromDate, to: toDate).year, interval > 0  {

            return interval == 1 ? "\(interval)" + " " + "year ago" : "\(interval)" + " " + "y"
        }

        // Month
        if let interval = Calendar.current.dateComponents([.month], from: fromDate, to: toDate).month, interval > 0  {

            return interval == 1 ? "\(interval)" + " " + "month ago" : "\(interval)" + " " + "mo"
        }

        // Day
        if let interval = Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day, interval > 0  {

            return interval == 1 ? "\(interval)" + " " + "day ago" : "\(interval)" + " " + "d"
        }

        // Hours
        if let interval = Calendar.current.dateComponents([.hour], from: fromDate, to: toDate).hour, interval > 0 {

            return interval == 1 ? "\(interval)" + " " + "hour ago" : "\(interval)" + " " + "hr"
        }

        // Minute
        if let interval = Calendar.current.dateComponents([.minute], from: fromDate, to: toDate).minute, interval > 0 {

            return interval == 1 ? "\(interval)" + " " + "minute ago" : "\(interval)" + " " + "m"
        }

        return "a moment ago"
    }
}
