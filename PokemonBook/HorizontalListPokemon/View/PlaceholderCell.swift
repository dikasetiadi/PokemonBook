//
//  PlaceholderCell.swift
//  PokemonBook
//
//  Created by Nakama on 02/01/20.
//  Copyright © 2020 dikasetiadi. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import UIKit

internal class PlaceholderCell: ASCellNode {
    private let startLocations : [NSNumber] = [-1.0,-0.5, 0.0]
    private let endLocations : [NSNumber] = [1.0,1.5, 2.0]
    private let gradientBackgroundColor : CGColor = UIColor(white: 0.85, alpha: 1.0).cgColor
    private let gradientMovingColor : CGColor = UIColor(white: 0.75, alpha: 1.0).cgColor
    private let movingAnimationDuration : CFTimeInterval = 0.8
    private let delayBetweenAnimationLoops : CFTimeInterval = 0.5
    
    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.frame = self.bounds
        layer.startPoint = CGPoint(x: 0.0, y: 1.0)
        layer.endPoint = CGPoint(x: 1.0, y: 1.0)
        layer.colors = [self.gradientBackgroundColor, self.gradientMovingColor, self.gradientBackgroundColor]
        layer.locations = startLocations
        layer.cornerRadius = 8
        
        return layer
    }()
    
    private lazy var gradientNode: ASDisplayNode = {
        let node = ASDisplayNode { [weak self] () -> CALayer in
            guard let self = self else { return CALayer() }

            let baseLayer = CALayer()
            baseLayer.addSublayer(self.gradientLayer)
            return baseLayer
        }
        node.style.flexBasis = ASDimensionMake("100%")
        node.style.flexGrow = 1
        return node
    }()
    
    override init() {
        super.init()
        
        backgroundColor = .white
        cornerRadius = 8
        automaticallyManagesSubnodes = true
        clipsToBounds = false

        shadowColor = #colorLiteral(red: 0.1921568627, green: 0.2078431373, blue: 0.231372549, alpha: 1).cgColor
        shadowOffset = CGSize(width: 0, height: 1)
        shadowOpacity = 0.12
        shadowRadius = 6
    }
        
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASWrapperLayoutSpec(layoutElement: gradientNode)
    }
    
    internal func startAnimation() {
        guard gradientLayer.animation(forKey: "locations") == nil else { return }
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = self.startLocations
        animation.toValue = self.endLocations
        animation.duration = self.movingAnimationDuration
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = self.movingAnimationDuration + self.delayBetweenAnimationLoops
        animationGroup.animations = [animation]
        animationGroup.repeatCount = .greatestFiniteMagnitude
        
        gradientLayer.add(animationGroup, forKey: animation.keyPath)
    }
    
    internal func stopAnimation() {
        gradientLayer.removeAllAnimations()
    }
}
