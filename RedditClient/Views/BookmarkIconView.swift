//
//  BookmarkIconView.swift
//  RedditClient
//
//  Created by Yaroslav on 24.11.2020.
//  Copyright © 2020 Yaroslav. All rights reserved.
//

import UIKit

extension CGRect {
    var centerX: CGFloat { (minX + maxX) / 2}
    var centerY: CGFloat { (minY + maxY) / 2}
}

final class BookmarkIconView: UIView {

    var pastLayer: CAShapeLayer? = nil

    private func makeLayer() -> CAShapeLayer {
        if let drawing = pastLayer {
            drawing.removeFromSuperlayer()
        }
        self.pastLayer = CAShapeLayer()
        return self.pastLayer!
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let drawing = makeLayer()
        
        let path = UIBezierPath()
        
        let lineWidth: CGFloat = 12

        path.move(to: CGPoint(x: bounds.minX + lineWidth, y: bounds.minY + lineWidth))
        path.addLine(to: CGPoint(x: bounds.maxX - lineWidth, y: bounds.minY + lineWidth))
        path.addLine(to: CGPoint(x: bounds.maxX - lineWidth, y: bounds.maxY - lineWidth))
        path.addLine(to: CGPoint(x: bounds.centerX, y: bounds.minX + bounds.width * 0.75))
        path.addLine(to: CGPoint(x: bounds.minX + lineWidth, y: bounds.maxY - lineWidth))
        path.close()
        
        drawing.path = path.cgPath
        drawing.fillColor = UIColor.white.cgColor
        drawing.strokeColor = UIColor.white.cgColor
        drawing.lineWidth = lineWidth
        drawing.lineJoin = .round
        
        drawing.shadowColor = UIColor.black.cgColor
        drawing.shadowRadius = 10
        drawing.shadowOpacity = 0.2
        
        layer.opacity = 0
        
        layer.addSublayer(drawing)
    }
    
    func animateSplash() {
        let group = CAAnimationGroup()
    
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = 0.6
        scale.toValue = 1
        scale.duration = 0.5
        scale.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        let fadeIn = CABasicAnimation(keyPath: "opacity")
        fadeIn.fillMode = .forwards
        fadeIn.fromValue = 0
        fadeIn.toValue = 0.8
        fadeIn.duration = 0.3
        
        let fadeOut = CABasicAnimation(keyPath: "opacity")
        fadeOut.fromValue = 0.8
        fadeOut.toValue = 0
        fadeOut.duration = 0.2
        fadeOut.beginTime = CACurrentMediaTime() + 0.3
        layer.add(fadeOut, forKey: nil)

        group.animations = [scale, fadeIn]
        group.duration = 0.5
        
        layer.opacity = 0

        layer.add(group, forKey: nil)
    }

}
