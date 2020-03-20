//
//  Extensions.swift
//  Coronavirus
//
//  Created by Shomil Jain on 3/19/20.
//  Copyright © 2020 Pineal Labs. All rights reserved.
//

import Foundation
import SafariServices

extension UIViewController: SFSafariViewControllerDelegate {
    func openLink(withURL url: URL?, showReader: Bool = true) {
        if let link = url {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = showReader
            let svc = SFSafariViewController(url: link, configuration: config)
            svc.delegate = self
            self.present(svc, animated: true, completion: nil)
        } else {

        }
    }
}

extension Int {
    
    func abbr() -> String {
        return self.abbreviated
    }

}

extension Int {
    var abbreviated: String {
        let abbrev = "KMBTPE"
        return abbrev.enumerated().reversed().reduce(nil as String?) { accum, tuple in
            let factor = Double(self) / pow(10, Double(tuple.0 + 1) * 3)
            let format = (factor.truncatingRemainder(dividingBy: 1)  == 0 ? "%.0f%@" : "%.1f%@")
            return accum ?? (factor > 1 ? String(format: format, factor, String(tuple.1)) : nil)
            } ?? String(self)
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
