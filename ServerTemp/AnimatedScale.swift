//
//  AnimatedScale.swift
//  CG
//
//  Created by BdevNameless on 12.12.15.
//  Copyright © 2015 Nikita Karaulov. All rights reserved.
//

import UIKit

@IBDesignable class AnimatedScale: UIControl {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSublayers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createSublayers()
    }
    
    //PRIVATE ATTRIBUTES
    private let pi = CGFloat(M_PI)
    
    private var renderer = ScaleRenderer()
    
    private var _temp: Double = 30
    
    internal var temp: Double {
        get { return _temp }
        set { setValue(newValue, animated: false) }
    }
    
    internal func setValue(value: Double, animated: Bool) {
        if value != _temp {
            let valueToSet = min(maxValue, max(minValue, value))
            let delta = valueToSet - _temp
            _temp = valueToSet
            let angleToRotate = CGFloat(delta) * anglePerDegree()
            renderer.setPointerAngle(angleToRotate, animated: animated)
        }
    }
    
    internal func testRotation() {
        let angle = pi * 0.1
        renderer.pointerLayer.transform = CATransform3DMakeRotation(angle, 0.0, 0.0, 0.1)
    }
    
    //PUBLIC ATTRIBUTES
    internal var minValue: Double = 15
    internal var maxValue: Double = 45
    
    
    @IBInspectable var scaleStrokeWidth: CGFloat = 4.0{
        didSet{
            setNeedsDisplayInRect(bounds)
        }
    }
    @IBInspectable var margin: CGFloat = 10.0 {
        didSet{
            setNeedsDisplayInRect(bounds)
        }
    }
    @IBInspectable var topOffset: CGFloat = 40 {
        didSet {
            renderer.topOffset = topOffset
            renderer.updatePointerBounds(bounds)
        }
    }
    @IBInspectable var arcDeep: CGFloat = 19 {
        didSet {
            renderer.arcDeep = arcDeep
            renderer.updatePointerPath()
        }
    }
    @IBInspectable var scaleStrokeColor: UIColor = UIColor.blackColor() {
        didSet{
            setNeedsDisplayInRect(bounds)
        }
    }
    @IBInspectable var gradStartColor: UIColor = UIColor.greenColor() {
        didSet{
            setNeedsDisplayInRect(bounds)
        }
    }
    @IBInspectable var gradMidColor: UIColor = UIColor.yellowColor() {
        didSet{
            setNeedsDisplayInRect(bounds)
        }
    }
    @IBInspectable var gradEndColor: UIColor = UIColor.redColor() {
        didSet{
            setNeedsDisplayInRect(bounds)
        }
    }
    @IBInspectable var pointerHeight: CGFloat = 5 {
        didSet {
            renderer.pointerHeight = pointerHeight
            renderer.updatePointerPath()
        }
    }
    @IBInspectable var pointerColor: UIColor = UIColor.blackColor() {
        didSet {
            renderer.pointerColor = pointerColor
            renderer.updatePointerPath()
        }
    }
    @IBInspectable var pointerStrokeWidth: CGFloat = 3.5 {
        didSet {
            renderer.pointerStrokeWidth = pointerStrokeWidth
            renderer.updatePointerPath()
        }
    }
    @IBInspectable var radius: CGFloat = 200 {
        didSet {
            renderer.radius = radius
            renderer.updatePointerBounds(bounds)
        }
    }
    @IBInspectable var startAngle: CGFloat = 135 {
        didSet {
            renderer.startAngle = startAngle
            renderer.updatePointerPath()
        }
    }
    @IBInspectable var endAngle: CGFloat = 165 {
        didSet {
            renderer.endAngle = endAngle
            renderer.updatePointerPath()
        }
    }
    var animationDuration: Double = 0.5 {
        didSet {
            renderer.animationDuration = animationDuration
        }
    }
    
    
    //PUBLIC METHODS
    
    override func layoutSubviews() {
        super.layoutSubviews()
        renderer.updatePointerBounds(bounds)
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        scaleStrokeColor.setStroke()
        let path = UIBezierPath()
        //radial way
        path.lineWidth = scaleStrokeWidth
        path.addArcWithCenter(CGPoint(x: bounds.width/2, y: topOffset+radius), radius: radius, startAngle: startAngle*pi/100, endAngle: endAngle*pi/100, clockwise: true)
        path.addArcWithCenter(CGPoint(x: bounds.width/2, y: topOffset+radius), radius: radius-arcDeep, startAngle: endAngle*pi/100, endAngle: startAngle*pi/100, clockwise: false)
        path.closePath()
        path.stroke()
        // GRADIENT
        CGContextSaveGState(context)
        path.addClip()
        let colors = [gradStartColor.CGColor, gradMidColor.CGColor, gradEndColor.CGColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations:[CGFloat] = [0.0, 0.5, 1.0]
        let gradient = CGGradientCreateWithColors(colorSpace, colors, colorLocations)
        let startPoint = CGPoint(x: margin, y: bounds.height/2)
        let endPoint = CGPoint(x: bounds.width-margin, y: bounds.height/2)
        CGContextDrawLinearGradient(context,
            gradient,
            startPoint,
            endPoint,
            CGGradientDrawingOptions.DrawsAfterEndLocation)
        CGContextRestoreGState(context)
    }
    
    //PRIVATE METHODS
    private func anglePerDegree() -> CGFloat {
        return (endAngle-startAngle)/30
    }
    
    private func createSublayers() {
        createPointerLayer()
    }
    
    private func createPointerLayer() {
        renderer.updatePointerBounds(bounds)
        layer.addSublayer(renderer.pointerLayer)
    }
    
}

private class ScaleRenderer {
    
    private func anglePerDegree() -> CGFloat {
        return (endAngle-startAngle)/30
    }
    
    init() {
        pointerLayer.fillColor = UIColor.clearColor().CGColor
        pointerLayer.backgroundColor = UIColor.clearColor().CGColor
    }
    
    private let pi = CGFloat(M_PI)
    private let pointerLayer = CAShapeLayer()
    
    
    var topOffset: CGFloat = 40
    var arcDeep: CGFloat = 19
    var pointerHeight: CGFloat = 5
    var pointerColor: UIColor = UIColor.blackColor()
    var pointerStrokeWidth: CGFloat = 3.5
    var radius: CGFloat = 200
    var startAngle: CGFloat = 135
    var endAngle: CGFloat = 165
    var animationDuration: Double = 0.5
    
    private func updatePointerBounds(bounds: CGRect) {
        pointerLayer.bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.width, height: (radius + topOffset) * 2)
        pointerLayer.position = CGPoint(x: bounds.width / 2.0, y: radius + topOffset)
        updatePointerPath()
    }
    
    private func updatePointerPath() {
        pointerLayer.strokeColor = pointerColor.CGColor
        pointerLayer.lineWidth = pointerStrokeWidth
        let pointerPath = UIBezierPath()
        pointerPath.moveToPoint(CGPoint(x: pointerLayer.bounds.width/2, y: arcDeep + topOffset))
        pointerPath.addLineToPoint(CGPoint(x: pointerLayer.bounds.width/2, y: topOffset + arcDeep - pointerHeight))
        pointerLayer.path = pointerPath.CGPath
    }
    
    private var backingPointerAngle: CGFloat = 150
    
    var pointerAngle: CGFloat {
        get { return backingPointerAngle }
        set { setPointerAngle(newValue, animated: false) }
    }
    
    func setPointerAngle(pointerAngle: CGFloat, animated: Bool) {
        let angleToRotate = pointerAngle - (150 - backingPointerAngle)
        let realAngle = (angleToRotate/100)*pi
        let currentAngle = ((backingPointerAngle - 150) / 100) * pi
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        pointerLayer.transform = CATransform3DMakeRotation(realAngle, 0.0, 0.0, 1.0)
        if animated {
            let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
            animation.values = [currentAngle, realAngle]
            animation.keyTimes = [0.0, 1.0]
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            animation.duration = animationDuration
            pointerLayer.addAnimation(animation, forKey: nil)
        }
        CATransaction.commit()
        self.backingPointerAngle += pointerAngle
    }

}
