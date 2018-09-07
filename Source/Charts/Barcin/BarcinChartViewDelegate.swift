//
//  BarcinChartViewDelegate.swift
//  Charts
//
//  Created by Gökhan Akkurt on 6.09.2018.
//

import UIKit

@objc public protocol BarcinChartViewDelegate : ChartViewDelegate
{
    @objc optional func chartValueSelected(chartView: ChartViewBase, entries: [ChartDataEntry], dataSetIndexes: [Int], highlights: [Highlight])
}
