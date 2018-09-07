//
//  BarcinLineChartView.swift
//  Charts
//
//  Created by Gökhan Akkurt on 6.09.2018.
//

import Foundation

open class BarcinLineChartView : LineChartView {
    
    public var barcinDelegate: BarcinChartViewDelegate? {
        get { return self.delegate as? BarcinChartViewDelegate }
        set { self.delegate = newValue }
    }
    
    public var hValues : [Highlight] = []
    
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
    
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
    
    @objc func detectPan(recognizer: UIPanGestureRecognizer) {
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
                    self.highlightValue(h)
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
    
    public func highlightValues(highs: [Highlight]?, callDelegate: Bool)
    {
        _indicesToHighlight = highs ?? [Highlight]()
        
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
                    barcinDataEntries.append((_data?.entryForHighlight(high))!)
                    barcinDataIndexes.append(high.dataSetIndex)
                }
                barcinDelegate?.chartValueSelected!(chartView: self, entries: barcinDataEntries, dataSetIndexes: barcinDataIndexes, highlights: highs!)
            }
        }
        
        // redraw the chart
        setNeedsDisplay()
    }
    
    open override func nsuiTouchesBegan(_ touches: Set<NSUITouch>, withEvent event: NSUIEvent?) {
        self.hValues = []
        self.totalTouches = (event?.touches(for: self)?.count)!
        if (event?.touches(for: self)?.count)! <= 2 {
            for touch in (event?.touches(for: self))! {
                if let chartH = getHighlightByTouchPoint(touch.location(in: self)){
                    self.hValues.append(chartH)
                }
            }
            
            let arr: [Highlight] = self.hValues
            self.highlightValues(highs: arr, callDelegate: true)
        }
    }
    
    open override func nsuiTouchesEnded(_ touches: Set<NSUITouch>, withEvent event: NSUIEvent?) {
        self.totalTouches -= touches.count
        
        for touch in touches {
            if let chartH = getHighlightByTouchPoint(touch.location(in: self)){
                let listOfHValues : [Highlight] = hValues
                for hValue in listOfHValues {
                    if hValue.x == chartH.x {
                        if let index = hValues.index(where: {$0 === hValue}){
                            hValues.remove(at: index)
                        }
                    }
                }
                
                let listOfIndices = _indicesToHighlight
                for indice in listOfIndices {
                    if indice.x == chartH.x {
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
                barcinDataEntries.append((_data?.entryForHighlight(high))!)
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
