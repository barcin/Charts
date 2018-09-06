//
//  BarcinLineChartDataSet.swift
//  Charts
//
//  Created by Gökhan Akkurt on 6.09.2018.
//

import Foundation

public class BarcinLineChartDataSet : LineChartDataSet {
    
    public var tag : Int = 0
    
    public var gradientColors : CFArray = [] as CFArray
    
    public var highlightGradientColors : CFArray = [] as CFArray
    
    public var fillGradientEnabled = false
    
    public var highlightLineColor : UIColor?
    
    public var isFillGradientEnabled : Bool {
        return fillGradientEnabled
    }
}

