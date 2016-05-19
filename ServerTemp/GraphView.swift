//
//  GraphView.swift
//  CG
//
//  Created by BdevNameless on 11.12.15.
//  Copyright © 2015 Nikita Karaulov. All rights reserved.
//

import UIKit

@IBDesignable class GraphView: UIView {
    
    //MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Attributes
    private var data: [Double] = []
    private var dates: [NSDate] = []
    private var labels: [UILabel] = []
    
    internal var report: [ReportValue] = [] {
        didSet {
            report.sortInPlace() { (rep1, rep2) in
                return rep1.date?.timeIntervalSince1970 < rep2.date?.timeIntervalSince1970
            }
            for item in report {
                data.append(item.value!)
                dates.append(item.date!)
            }
            setNeedsDisplayInRect(bounds)
        }
    }
    
    @IBInspectable var areaTopOffset: CGFloat = 10
    @IBInspectable var areaBotOffset: CGFloat = 10
    @IBInspectable var areaCornerRadius: CGFloat = 5
    @IBInspectable var areaColor1: UIColor = UIColor.blackColor()
    @IBInspectable var areaColor2: UIColor = UIColor.lightGrayColor()
    
    @IBInspectable var graphLeftMargin: CGFloat = 5
    @IBInspectable var graphRightMargin: CGFloat = 15
    @IBInspectable var graphTopOffset: CGFloat = 0
    @IBInspectable var graphBotOffset: CGFloat = 0
    @IBInspectable var graphLineWidth: CGFloat = 2
    @IBInspectable var graphLineColor: UIColor = UIColor.greenColor()
    @IBInspectable var graphGradColor1: UIColor = UIColor.clearColor()
    @IBInspectable var graphGradColor2: UIColor = UIColor.clearColor()
    @IBInspectable var graphCircleSize: CGFloat = 5
    @IBInspectable var graphBackLineColor: UIColor = UIColor.greenColor()
    @IBInspectable var graphBackLineWidth: CGFloat = 3
    
    
    //MARK: - Methods
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        // AREA BASIC CLIP
        let graphRect = CGRect(x: 0, y: areaTopOffset, width: bounds.width, height: bounds.height-areaTopOffset-areaBotOffset)
        let clipPath = UIBezierPath(roundedRect: graphRect, cornerRadius: areaCornerRadius)
        CGContextSaveGState(context)
        clipPath.addClip()
        // AREA GRADIENT
        let areaGradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(),
            [areaColor1.CGColor, areaColor2.CGColor], [0.0, 1.0])
        CGContextDrawLinearGradient(context,
            areaGradient,
            CGPoint(x: 0, y: areaTopOffset),
            CGPoint(x: 0, y: bounds.height-areaBotOffset),
            .DrawsAfterEndLocation)
        CGContextRestoreGState(context)
        // LINES
        graphBackLineColor.setStroke()
        let topline = UIBezierPath()
        topline.lineWidth = graphBackLineWidth
        topline.moveToPoint(CGPoint(x: graphLeftMargin, y: graphTopOffset))
        topline.addLineToPoint(CGPoint(x: bounds.width - graphRightMargin, y: graphTopOffset))
        topline.moveToPoint(CGPoint(x: graphLeftMargin, y: graphTopOffset + graphHeight()/2))
        topline.addLineToPoint(CGPoint(x: bounds.width - graphRightMargin, y: graphTopOffset + graphHeight()/2))
        topline.moveToPoint(CGPoint(x: graphLeftMargin, y: bounds.height - graphBotOffset))
        topline.addLineToPoint(CGPoint(x: bounds.width - graphRightMargin, y: bounds.height - graphBotOffset))
        topline.stroke()
        if (data.count > 0)&&(data.count == dates.count) {
            // GRAPHIC LINE
            let graphPath = UIBezierPath()
            graphPath.moveToPoint(pointForValue(0))
            for i in 1...data.count-1 {
                graphPath.addLineToPoint(pointForValue(i))
            }
            graphPath.lineWidth = graphLineWidth
            graphLineColor.setStroke()
            graphPath.stroke()
            // UNDERLINE GRADIENT
            CGContextSaveGState(context)
            let gClipPath = graphPath.copy()
            gClipPath.addLineToPoint(CGPoint(x: bounds.width - graphRightMargin, y: bounds.height - graphBotOffset))
            gClipPath.addLineToPoint(CGPoint(x: graphLeftMargin, y: bounds.height - graphBotOffset))
            gClipPath.closePath()
            gClipPath.addClip()
            let unlineGradient = CGGradientCreateWithColors(CGColorSpaceCreateDeviceRGB(), [graphGradColor1.CGColor, graphGradColor2.CGColor], [0.0, 1.0])
            CGContextDrawLinearGradient(context,
                unlineGradient,
                CGPoint(x: graphLeftMargin, y: graphTopOffset),
                CGPoint(x: graphLeftMargin, y: bounds.height - areaBotOffset - graphBotOffset),
                .DrawsAfterEndLocation)
            CGContextRestoreGState(context)
            // CIRCLES
            graphLineColor.setFill()
            for i in 0...data.count-1 {
                var point = pointForValue(i)
                point.x -= graphCircleSize/2
                point.y -= graphCircleSize/2
                let circle = UIBezierPath(ovalInRect: CGRect(origin: point, size: CGSize(width: graphCircleSize, height: graphCircleSize)))
                circle.fill()
            }
            updateLabels()
        }
    }
    
    //MARK: - Private Methods
    private func pointForValue(value: Int) -> CGPoint {
        return CGPoint(x: xForColumn(value), y: yForColumn(value))
    }
    
    private func graphWidth() -> CGFloat {
        return bounds.width - graphRightMargin - graphLeftMargin
    }
    
    private func graphHeight() -> CGFloat {
        return bounds.height - graphTopOffset - graphBotOffset
    }
    
    private func xForColumn(column: Int) -> CGFloat {
        let perColumnX = graphWidth() / CGFloat(data.count - 1)
        return CGFloat(perColumnX * CGFloat(column) + graphLeftMargin)
    }
    
    private func yForColumn(column: Int) -> CGFloat {
        // Для отображения десятых долей градуса
        let perTenthDegreeY = graphHeight() / CGFloat((data.maxElement()!-15)*10)
        return bounds.height - graphBotOffset - perTenthDegreeY * CGFloat((data[column]-15)*10)
    }
    
    private func updateLabels() {
        if labels.isEmpty {
            addLabels()
        }
        else {
            updateLabelsFrames()
        }
    }
    
    private func updateLabelsFrames() {
        for label in labels {
            var newFrame = label.frame
            newFrame.origin = CGPoint(x: xForColumn(labels.indexOf(label)!) - graphLeftMargin, y: bounds.height - graphBotOffset + 7)
            label.frame = newFrame
        }
    }
    
    lazy private var hoursDateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.timeZone = NSTimeZone.systemTimeZone()
        formatter.dateFormat = "HH"
        return formatter
    }()
    
    private func addLabels() {
        for i in 0..<dates.count {
            let newLabel = UILabel(frame: CGRect(x: xForColumn(i) - graphLeftMargin, y: bounds.height - graphBotOffset + 7, width: graphWidth() / CGFloat(data.count - 1), height: 10))
            print(dates[i])
            print(hoursDateFormatter.stringFromDate(dates[i]))
            newLabel.text = hoursDateFormatter.stringFromDate(dates[i])
            newLabel.textColor = UIColor.init(red: (128 / 255), green: 1.0, blue: 0.0, alpha: 1.0)
            newLabel.font = newLabel.font.fontWithSize(10)
            addSubview(newLabel)
            labels.append(newLabel)
        }
        setNeedsDisplay()
    }
    
}
