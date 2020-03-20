//
//  ViewController.swift
//  Coronavirus
//
//  Created by Shomil Jain on 3/19/20.
//  Copyright © 2020 Pineal Labs. All rights reserved.
//

import UIKit
import Charts
import Segmentio
import QuartzCore

class GraphCell: UITableViewCell, ChartViewDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var percentChangeLabel: UILabel!
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var segmentedControl: Segmentio!
    
    var selectedIndex: Int? = 0
    var selectedView: String?
    
    func update(forRegion region: RegionModel, selectedGraphView: String?, overrideTitle: String? = nil) {
        if let t = overrideTitle {
            titleLabel.text = t
        } else {
            titleLabel.text = region.country
        }
        subtitleLabel.text = "\(region.numCases.abbr()) Cases"
        let isGreen = region.oneDayPercent <= 0
        if isGreen {
            percentChangeLabel.textColor = UIColor.flatTurquoise
            percentChangeLabel.text = "- \(region.oneDayNumber.abbr()) (\(region.oneDayPercent.rounded(toPlaces: 2))%)"
        } else {
            percentChangeLabel.textColor = UIColor.flatAlizarin
            percentChangeLabel.text = "+ \(region.oneDayNumber.abbr()) (\(region.oneDayPercent.rounded(toPlaces: 2))%)"
        }
        
        ChartUtil.renderChart(chartView: chartView, isGreen: isGreen, region: region, delegate: self, selectedGraphView: selectedGraphView)
        setupSegmentio(region: region, isGreen: isGreen)
    }
    
    
    func setupSegmentio(region: RegionModel, isGreen: Bool) {
        let keys = region.timeSeriesKeys
        var items = [SegmentioItem]()
        for k in keys {
            items.append(SegmentioItem(title: k.uppercased(), image: nil))
        }
        var mainColor = UIColor.flatAlizarin
        if isGreen {
            mainColor = UIColor.flatEmerald
        }
        segmentedControl.setup(
            content: items,
            style: SegmentioStyle.onlyLabel,
            options: SegmentioOptions(backgroundColor: .white, segmentPosition: .fixed(maxVisibleItems: 3), scrollEnabled: false, indicatorOptions: SegmentioIndicatorOptions(type: .bottom, ratio: 0.8, height: 0.7, color: mainColor), horizontalSeparatorOptions: SegmentioHorizontalSeparatorOptions(type: .none, height: 0, color: UIColor.white), verticalSeparatorOptions: SegmentioVerticalSeparatorOptions(ratio: 0, color: UIColor.white), imageContentMode: .bottom, labelTextAlignment: .center, labelTextNumberOfLines: 0, segmentStates: SegmentioStates(
                defaultState: SegmentioState(
                    backgroundColor: .clear,
                    titleFont:                     UIFont(name: "Avenir-Book", size: 12.0)!,
                    titleTextColor: .lightGray
                ),
                selectedState: SegmentioState(
                    backgroundColor: .clear,
                    titleFont: UIFont(name: "Avenir-Book", size: 12.0)!,
                    titleTextColor: .darkGray
                ),
                highlightedState: SegmentioState(
                    backgroundColor: .clear,
                    titleFont:
                    UIFont(name: "Avenir-Book", size: 12.0)!,
                    titleTextColor: .lightGray
                )
                )
            )
        )
        segmentedControl.selectedSegmentioIndex = 0
        segmentedControl.valueDidChange = { segmentio, segmentIndex in
            print("Rendering new chart!")
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            ChartUtil.renderChart(chartView: self.chartView, isGreen: isGreen, region: region, delegate: self, selectedGraphView: region.timeSeriesKeys[segmentIndex])
            switch region.timeSeriesKeys[segmentIndex] {
            case "Cases":
                self.subtitleLabel.text = "\(region.numCases.abbr()) Cases"
            case "Deaths":
                self.subtitleLabel.text = "\(region.numDead.abbr()) Deaths"
            case "Recovered":
                self.subtitleLabel.text = "\(region.numRecovered.abbr()) Recovered"
            default:
                self.subtitleLabel.text = "\(region.numCases.abbr()) Cases"
            }
        }
        
    }
    
}


class TickerCell: UITableViewCell, ChartViewDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var graphView: LineChartView!
    @IBOutlet weak var deltaLabel: UILabel!
    
    func update(forRegion region: RegionModel) {
        if region.region == "nan" {
            titleLabel.text = region.country
        } else {
            titleLabel.text = region.region
        }
        subtitleLabel.text = "\(region.numCases.abbr()) cases"
        let isGreen = region.oneDayPercent <= 0
        if isGreen {
            deltaLabel.backgroundColor = UIColor.flatEmerald
            deltaLabel.text = "-\(Int(region.oneDayPercent.rounded()).abbr())%"
        } else {
            deltaLabel.backgroundColor = UIColor.flatAlizarin
            deltaLabel.text = "+\(Int(region.oneDayPercent.rounded()).abbr())%"
        }
        deltaLabel.layer.cornerRadius = 4
        deltaLabel.layer.masksToBounds = true
        ChartUtil.renderChart(chartView: graphView, isGreen: isGreen, region: region, delegate: self)
    }
}

struct ChartUtil {
    
    static func renderChart(chartView: LineChartView, isGreen: Bool, region: RegionModel, delegate: ChartViewDelegate, selectedGraphView: String? = nil) {
        
        chartView.delegate = delegate
        chartView.chartDescription?.enabled = false
        chartView.dragEnabled = false
        chartView.setScaleEnabled(false)
        chartView.pinchZoomEnabled = false
        chartView.xAxis.axisLineColor = .lightGray
        chartView.leftAxis.enabled = false
        chartView.rightAxis.enabled = false
        chartView.xAxis.enabled = false
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.leftAxis.drawGridLinesEnabled = false
        chartView.rightAxis.drawGridLinesEnabled = false
        chartView.legend.enabled = false
        
        chartView.highlightPerTapEnabled = false
        
        chartView.leftAxis.spaceBottom = 0.1
        
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: region.timeSeriesX)
        let selectedGraph: String? = selectedGraphView ?? region.timeSeriesKeys.first
        
        guard let selected = selectedGraph else { return }
        
        guard let yData = region.timeSeriesY[selected] else { return }
        let xData = region.timeSeriesX
        var entries = [BarChartDataEntry]()
        for i in 0..<xData.count {
            entries.append(BarChartDataEntry(x: Double(i), y: Double(yData[i])))
        }
        
        let chartDataSet = LineChartDataSet(entries: entries)
        chartDataSet.drawHorizontalHighlightIndicatorEnabled = false
        chartDataSet.drawCirclesEnabled = false
        chartDataSet.drawValuesEnabled = false
        chartDataSet.lineWidth = 1.5
        
        if isGreen {
            chartDataSet.setColor(UIColor.flatEmerald)
        } else {
            chartDataSet.setColor(UIColor.flatAlizarin)
        }
        let chartData = LineChartData(dataSet: chartDataSet)
        chartView.data = chartData
    }
    
}

class NumbersCell: UITableViewCell {
    
    @IBOutlet weak var labelOne: UILabel!
    @IBOutlet weak var labelTwo: UILabel!
    @IBOutlet weak var labelThree: UILabel!
    @IBOutlet weak var valueOne: UILabel!
    @IBOutlet weak var valueTwo: UILabel!
    @IBOutlet weak var valueThree: UILabel!
    
}

class HeaderCell: UITableViewCell {
    
    @IBOutlet weak var headerLabel: UILabel!
    
}


class SummaryCell: UITableViewCell {
    
    @IBOutlet weak var labelOne: UILabel!
    @IBOutlet weak var labelTwo: UILabel!
    @IBOutlet weak var labelThree: UILabel!
    @IBOutlet weak var labelFour: UILabel!
    @IBOutlet weak var labelFive: UILabel!
    @IBOutlet weak var labelSix: UILabel!
    @IBOutlet weak var valueOne: UILabel!
    @IBOutlet weak var valueTwo: UILabel!
    @IBOutlet weak var valueThree: UILabel!
    @IBOutlet weak var valueFour: UILabel!
    @IBOutlet weak var valueFive: UILabel!
    @IBOutlet weak var valueSix: UILabel!
    
    func update(forRegion r: RegionModel) {
        self.valueOne.text = r.numCases.abbr()
        self.valueTwo.text = r.numDead.abbr()
        self.valueThree.text = r.numRecovered.abbr()
        self.valueFour.text = r.oneDayNumber.abbr()
        self.valueFive.text = r.fiveDayNumber.abbr()
        self.valueSix.text = r.tenDayNumber.abbr()
    }
    
}

class NewsCell: UITableViewCell {
    
    @IBOutlet weak var publisherLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var newsImage: UIImageView!
    
}
