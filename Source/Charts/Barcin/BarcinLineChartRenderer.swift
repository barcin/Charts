//
//  BarcinLineChartRenderer.swift
//  Charts
//
//  Created by Gökhan Akkurt on 6.09.2018.
//

import Foundation

public class BarcinLineChartRenderer : LineChartRenderer {
    
    private var _highlightPointBuffer = CGPoint()
    
    private var _lineSegments = [CGPoint](repeating: CGPoint(), count: 2)
    
    public override func drawLinearFill(context: CGContext, dataSet: ILineChartDataSet, trans: Transformer, bounds: BarLineScatterCandleBubbleRenderer.XBounds) {
        guard let dataProvider = dataProvider else { return }
        
        context.saveGState()
        
        let phaseX = Swift.max(0.0, Swift.min(1.0, animator.phaseX))
        let bounds = BarLineScatterCandleBubbleRenderer.XBounds()
        bounds.min = Int(dataSet.xMin)
        bounds.max = Int(dataSet.xMax)
        bounds.range = Int(Double(bounds.max - bounds.min) * phaseX)
        
        let filled = super.generateFilledPath(dataSet: dataSet, fillMin: dataSet.fillFormatter?.getFillLinePosition(dataSet: dataSet, dataProvider: dataProvider) ?? 0.0, bounds: bounds, matrix: trans.valueToPixelMatrix)
    
        if let set = dataSet as? BarcinLineChartDataSet{
            if set.isFillGradientEnabled == true {
                
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
    
    public override func drawHighlighted(context: CGContext, indices: [Highlight]){
        guard let lineData = dataProvider?.lineData, let chartXMax = dataProvider?.chartXMax else { return }
        context.saveGState()
        var minx = 9999.9
        var maxx = 0.0
        
        for i in 0 ..< indices.count{
            guard let set = lineData.getDataSetByIndex(indices[i].dataSetIndex) as? BarcinLineChartDataSet else { continue }
            let trans = dataProvider?.getTransformer(forAxis: set.axisDependency)
            
            if !set.highlightEnabled { continue }
            
            
            let xIndex = indices[i].x;
            
            if xIndex < minx {
                minx = xIndex
            }
            
            if xIndex > maxx {
                maxx = xIndex
            }
            
            if CGFloat(xIndex) > CGFloat(chartXMax * animator.phaseX){
                continue
            }
            
            let yValue = set.values[Int(xIndex)].y
            if (yValue.isNaN) { continue }
            
            _highlightPointBuffer.x = CGFloat(xIndex)
            // get y position
            _highlightPointBuffer.y = CGFloat(yValue) * CGFloat(animator.phaseY)
            
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
            
            let xIndex = indices[i].x; // get the x-position
            
            if CGFloat(xIndex) > CGFloat(chartXMax * animator.phaseX){
                continue
            }
            
            let yValue = set.values[Int(xIndex)].y
            if (yValue.isNaN)
            {
                continue
            }
            
            _highlightPointBuffer.x = CGFloat(xIndex)
            // get y position
            _highlightPointBuffer.y = CGFloat(yValue) * CGFloat(animator.phaseY)
            
            let trans = dataProvider?.getTransformer(forAxis: set.axisDependency)
            
            trans?.pointValueToPixel(&_highlightPointBuffer)
            
            // draw the lines
            //drawHighlightLines(context: context, point: _highlightPointBuffer, set: set)
            
            let phaseX = Swift.max(0.0, Swift.min(1.0, animator.phaseX))
            let bounds = BarLineScatterCandleBubbleRenderer.XBounds()
            bounds.min = Int(minx)
            bounds.max = Int(maxx)
            bounds.range = Int(Double(bounds.max - bounds.min) * phaseX)
    
            let filled = super.generateFilledPath(dataSet: set, fillMin: set.fillFormatter?.getFillLinePosition(dataSet: set, dataProvider: dataProvider!) ?? 0.0, bounds: bounds, matrix: trans!.valueToPixelMatrix)
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
