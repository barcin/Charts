
//
//  BarcinLineChartView.swift
//  Charts
//
//  Created by Ali Bahşişoğlu on 30/11/15.
//  Copyright © 2015 dcg. All rights reserved.
//

import Foundation

@objc
public protocol BarcinChartViewDelegate : ChartViewDelegate
{
    @objc optional func chartValueSelected(chartView: ChartViewBase, entries: [ChartDataEntry], dataSetIndexes: [Int], highlights: [ChartHighlight])
}

public class BarcinLineChartView : LineChartView {
    
    public var barcinDelegate: BarcinChartViewDelegate? {
        get { return self.delegate as? BarcinChartViewDelegate }
        set { self.delegate = newValue }
    }
    
    public var hValues : [ChartHighlight] = []
    
    public var totalTouches : Int = 0
    
    internal override func initialize()
    {
        super.initialize()
        
        self.isMultipleTouchEnabled = true
        
        renderer = BarcinLineChartRenderer(dataProvider: self, animator: _animator, viewPortHandler: _viewPortHandler)
        
        self.removeGestureRecognizer(_tapGestureRecognizer)
        self.removeGestureRecognizer(_panGestureRecognizer)
        self.removeGestureRecognizer(_doubleTapGestureRecognizer)
        self.removeGestureRecognizer(_pinchGestureRecognizer)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.detectPan(recognizer:)))
        panGestureRecognizer.delegate = self
        panGestureRecognizer.cancelsTouchesInView = false
        panGestureRecognizer.delaysTouchesEnded = false
        self.addGestureRecognizer(panGestureRecognizer)
    }
    
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
    
    func detectPan(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.ended {
            _indicesToHighlight.removeAll()
            setNeedsDisplay()
            self.lastHighlighted = nil
            self.hValues = []
            delegate?.chartValueNothingSelected?(self)
        } else {
            if recognizer.numberOfTouches == 1 {
                let h = getHighlightByTouchPoint(recognizer.location(in: self))
                let lastHighlighted = self.lastHighlighted
                
                if ((h === nil && lastHighlighted !== nil) ||
                    (h !== nil && lastHighlighted === nil) ||
                    (h !== nil && lastHighlighted !== nil && !h!.isEqual(lastHighlighted)))
                {
                    self.lastHighlighted = h
                    self.highlightValue(highlight: h, callDelegate: true)
                }
            } else if recognizer.numberOfTouches == 2 {
                self.hValues = []
                for i in 1...recognizer.numberOfTouches {
                    let touch = recognizer.location(ofTouch: i-1, in: self)
                    if touch.x < self.frame.width - 20 {
                        if let chartH = getHighlightByTouchPoint(touch){
                            self.hValues.append(chartH)
                            self.highlightValues(highs: self.hValues, callDelegate: true)
                        }
                    }
                }
            } else {
                return;
            }
        }
        
    }
    
    public func highlightValues(highs: [ChartHighlight]?, callDelegate: Bool)
    {
        _indicesToHighlight = highs ?? [ChartHighlight]()
        
        if (_indicesToHighlight.isEmpty)
        {
            self.lastHighlighted = nil
        }
        else
        {
            self.lastHighlighted = _indicesToHighlight[0];
        }
        
        if (callDelegate && delegate != nil)
        {
            if (highs?.count == 0)
            {
                barcinDelegate!.chartValueNothingSelected?(self)
            }
            else
            {
                var barcinDataEntries:[ChartDataEntry] = []
                var barcinDataIndexes:[Int] = []
                for high in highs! {
                    barcinDataEntries.append((_data?.getEntryForHighlight(high))!)
                    barcinDataIndexes.append(high.dataSetIndex)
                }
                barcinDelegate?.chartValueSelected!(chartView: self, entries: barcinDataEntries, dataSetIndexes: barcinDataIndexes, highlights: highs!)
            }
        }
        
        // redraw the chart
        setNeedsDisplay()
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.hValues = []
        self.totalTouches = (event?.touches(for: self)?.count)!
        if (event?.touches(for: self)?.count)! <= 2 {
            for touch in (event?.touches(for: self))! {
                if let chartH = getHighlightByTouchPoint(touch.location(in: self)){
                    self.hValues.append(chartH)
                }
            }
            
            let arr: [ChartHighlight] = self.hValues
            self.highlightValues(highs: arr, callDelegate: true)
        }
    }
    
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.totalTouches -= touches.count
        
        for touch in touches {
            if let chartH = getHighlightByTouchPoint(touch.location(in: self)){
                let listOfHValues : [ChartHighlight] = hValues
                for hValue in listOfHValues {
                    if hValue.xIndex == chartH.xIndex {
                        if let index = hValues.index(where: {$0 === hValue}){
                            hValues.remove(at: index)
                        }
                    }
                }
                
                let listOfIndices = _indicesToHighlight
                for indice in listOfIndices {
                    if indice.xIndex == chartH.xIndex {
                        if let index = _indicesToHighlight.index(where: {$0 === indice}){
                            _indicesToHighlight.remove(at: index)
                        }
                    }
                }
            }
        }
        
        if self.totalTouches > 0 {
            var barcinDataEntries:[ChartDataEntry] = []
            var barcinDataIndexes:[Int] = []
            for high in _indicesToHighlight {
                barcinDataEntries.append((_data?.getEntryForHighlight(high))!)
                barcinDataIndexes.append(high.dataSetIndex)
            }
            barcinDelegate?.chartValueSelected!(chartView: self, entries: barcinDataEntries, dataSetIndexes: barcinDataIndexes, highlights: _indicesToHighlight)
        } else {
            self.lastHighlighted = nil
            delegate!.chartValueNothingSelected?(self)
        }
        
        setNeedsDisplay()
    }
    
}
