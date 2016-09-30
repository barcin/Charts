//
//  BarcinLineChartRenderer.swift
//  Charts
//
//  Created by Ali Bahşişoğlu on 30/11/15.
//  Copyright © 2015 dcg. All rights reserved.
//

import Foundation


public class BarcinLineChartRenderer : LineChartRenderer {
    
    private var _highlightPointBuffer = CGPoint()
    
    private var _lineSegments = [CGPoint](repeating: CGPoint(), count: 2)
    
    public override func drawLinearFill(context: CGContext, dataSet: ILineChartDataSet, minx: Int, maxx: Int, trans: ChartTransformer)
    {
        guard let dataProvider = dataProvider else { return }
        
        context.saveGState()
        
        let filled = generateFilledPath(
            dataSet: dataSet,
            fillMin: dataSet.fillFormatter?.getFillLinePosition(dataSet: dataSet, dataProvider: dataProvider) ?? 0.0,
            from: minx,
            to: maxx,
            matrix: trans.valueToPixelMatrix)
        
        if let set = dataSet as? BarcinLineChartDataSet{
            if set
                .isFillGradientEnabled == true {
                
                let colorSpace = CGColorSpaceCreateDeviceRGB()
                let colorLocations:[CGFloat] = [0.4, 1.0]
                let gradient = CGGradient(colorsSpace: colorSpace, colors: set.gradientColors, locations: colorLocations)
                
                context.setAlpha(CGFloat(0.33))
                context.beginPath()
                context.addPath(filled)
                context.clip()
                context.drawLinearGradient(gradient!, start: CGPoint.zero, end: CGPoint(x: 0, y: viewPortHandler.chartHeight*1.3), options: CGGradientDrawingOptions.drawsAfterEndLocation)
                
            } else {
                context.setFillColor(dataSet.fillColor.cgColor)
                
                // filled is usually drawn with less alpha
                context.setAlpha(dataSet.fillAlpha)
                context.beginPath()
                context.addPath(filled)
                context.fillPath()
            }
        }
        context.restoreGState()
    }
    
    public override func drawHighlighted(context: CGContext, indices: [ChartHighlight])
    {
        guard let lineData = dataProvider?.lineData, let chartXMax = dataProvider?.chartXMax else { return }
        context.saveGState()
        var minx = 9999
        var maxx = 0
        
        for i in 0 ..< indices.count{
            guard let set = lineData.getDataSetByIndex(indices[i].dataSetIndex) as? BarcinLineChartDataSet else { continue }
            let trans = dataProvider?.getTransformer(set.axisDependency)
            
            if !set.highlightEnabled { continue }
            
            
            let xIndex = indices[i].xIndex;
            
            if xIndex < minx {
                minx = xIndex
            }
            
            if xIndex > maxx {
                maxx = xIndex
            }
            
            if let anim = animator, CGFloat(xIndex) > (CGFloat(chartXMax) * anim.phaseX){
                continue
            }
            
            let yValue = set.yValForXIndex(xIndex)
            if (yValue.isNaN) { continue }
            
            _highlightPointBuffer.x = CGFloat(xIndex)
            if let anim = animator{
                // get y position
                _highlightPointBuffer.y = CGFloat(yValue) * anim.phaseY
            }
            
            trans?.pointValueToPixel(&_highlightPointBuffer)
            
            context.setStrokeColor(set.highlightColor.cgColor)
            context.setLineWidth(set.highlightLineWidth)
            context.beginPath()
            context.move(to: CGPoint(x:_highlightPointBuffer.x, y:viewPortHandler.contentTop))
            context.addLine(to: CGPoint(x:_highlightPointBuffer.x, y:viewPortHandler.contentBottom))
            context.strokePath()
        }
        
        for i in 0 ..< indices.count{
            guard let set = lineData.getDataSetByIndex(indices[i].dataSetIndex) as? BarcinLineChartDataSet else { continue }
            
            if !set.highlightEnabled { continue }
            
            context.setStrokeColor(set.highlightColor.cgColor)
            context.setLineWidth(set.highlightLineWidth)
            if (set.highlightLineDashLengths != nil){
                context.setLineDash(phase: set.highlightLineDashPhase, lengths: set.highlightLineDashLengths!)
            }
            else{
                context.setLineDash(phase: 0.0, lengths: [])
            }
            
            let xIndex = indices[i].xIndex; // get the x-position
            
            if let anim = animator, CGFloat(xIndex) > (CGFloat(chartXMax) * anim.phaseX){
                continue
            }
            
            let yValue = set.yValForXIndex(xIndex)
            if (yValue.isNaN)
            {
                continue
            }
            
            _highlightPointBuffer.x = CGFloat(xIndex)
            if let anim = animator{
                // get y position
                _highlightPointBuffer.y = CGFloat(yValue) * anim.phaseY
            }
            
            let trans = dataProvider?.getTransformer(set.axisDependency)
            
            trans?.pointValueToPixel(&_highlightPointBuffer)
            
            // draw the lines
            //drawHighlightLines(context: context, point: _highlightPointBuffer, set: set)
            
            let entries = set.yVals
            
            let filled = super.generateFilledPath(
                dataSet: entries as! ILineChartDataSet,
                fillMin: set.fillFormatter?.getFillLinePosition(dataSet: set, dataProvider: dataProvider!) ?? 0.0,
                from: minx,
                to: maxx+1,
                matrix: trans!.valueToPixelMatrix)
            
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let colorLocations:[CGFloat] = [0.4, 1.0]
            let gradient = CGGradient(colorsSpace: colorSpace, colors: set.highlightGradientColors, locations: colorLocations)
            context.setAlpha(CGFloat(0.8))
            context.beginPath()
            context.addPath(filled)
            context.clip()
            context.drawLinearGradient(gradient!, start: CGPoint.zero, end: CGPoint(x: 0, y: viewPortHandler.chartHeight*1.3), options: CGGradientDrawingOptions.drawsAfterEndLocation)
            
        }
        
        context.restoreGState()
    }
}
