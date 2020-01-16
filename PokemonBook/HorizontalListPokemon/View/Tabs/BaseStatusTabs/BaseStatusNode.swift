//
//  BaseStatusNode.swift
//  PokemonBook
//
//  Created by Nakama on 13/01/20.
//  Copyright © 2020 dikasetiadi. All rights reserved.
//

import AsyncDisplayKit

internal class BaseStatusNode: ASDisplayNode {
    private lazy var backgroundNode: ASDisplayNode = {
        let node = ASDisplayNode()
        node.backgroundColor = .lightGreyPallete
        node.style.height = ASDimensionMake(3)
        node.style.flexBasis = ASDimensionMake("100%")
        
        return node
    }()

    private let statusBackgroundNode: ASDisplayNode = {
        let node = ASDisplayNode()
        node.backgroundColor = .redPallete
        node.style.height = ASDimensionMake(3)
        node.style.flexBasis = ASDimensionMake(0)
        node.cornerRadius = 1.5
        node.clipsToBounds = true
        
        return node
    }()
    
    private lazy var statusTextNode: ASTextNode = {
        let node = ASTextNode()
        node.attributedText = NSAttributedString(string: statusRawData.title, attributes: [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold),
        NSAttributedString.Key.foregroundColor: UIColor.blackPallete.withAlphaComponent(0.6)])
        node.style.minWidth = ASDimensionMake(60)
        
        return node
    }()
    
    private lazy var statusValueTextNode: ASTextNode = {
        let node = ASTextNode()
        let value = Int(statusRawData.value)
        node.attributedText = NSAttributedString(string: "\(value)", attributes: [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold),
        NSAttributedString.Key.foregroundColor: UIColor.blackPallete])
        node.style.minWidth = ASDimensionMake(30)
        
        return node
    }()
    
    private let statusRawData: PokemonStatus
    private var maxComparationValue: CGFloat = 0
    private var displayLink: CADisplayLink? = nil
    private var startAnimationDate = Date()
    private let animationDuration: Double = 0.7
    private let defaultValueStatus: Int = 0
    private var isDoneAnimation = false
    
    init(data: PokemonStatus, maxComparationValue: CGFloat) {
        self.maxComparationValue = maxComparationValue
        statusRawData = data
        
        super.init()
        
        cornerRadius = 1.5
        clipsToBounds = true
        automaticallyManagesSubnodes = true
    }
    
    override func didLoad() {
        super.didLoad()
    }
        
    override func didExitDisplayState() {
        super.didExitDisplayState()
        
        resetAnimation()
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let statusBarStack = ASStackLayoutSpec.horizontal()
        statusBarStack.child = statusBackgroundNode

        let contentStack = ASBackgroundLayoutSpec(child: statusBarStack, background: backgroundNode)
        
        let innerLayout = ASStackLayoutSpec(direction: .vertical,
                                            spacing: 0,
                                            justifyContent: .start,
                                            alignItems: .stretch,
                                            children: [contentStack])
        innerLayout.style.flexGrow = 1
        
        let content = ASStackLayoutSpec.horizontal()
        content.spacing = 8
        content.alignItems = .center
        content.justifyContent = .center
        content.children = [
            statusTextNode,
            statusValueTextNode,
            innerLayout
        ]
        
        content.style.width = ASDimensionMake("100%")
        content.style.flexGrow = 1
        content.style.flexShrink = 1
        content.style.flexBasis = ASDimensionMake(.fraction, 1)

        return content
    }
    
    override func animateLayoutTransition(_ context: ASContextTransitioning) {
        super.animateLayoutTransition(context)
        
        let initialFrameProgress = context.initialFrame(for: statusBackgroundNode)

        statusBackgroundNode.frame = initialFrameProgress

        let finalFrameProgress = context.finalFrame(for: statusBackgroundNode)

        UIView.animate(withDuration: 0.7, animations: { [weak self] in
            guard let self = self else { return }
            
            let calculation: CGFloat = (self.statusRawData.value / self.maxComparationValue) * 100
            if calculation > 55 {
                self.statusBackgroundNode.backgroundColor = .tealPallete
            }
            
            self.statusBackgroundNode.frame = finalFrameProgress
        }, completion: { finished in
            context.completeTransition(finished)
        })
    }
    
    internal func startAnimation() {
        guard !isDoneAnimation else { return }
        
        setupDisplayLink()
        
        let calculation: CGFloat = (statusRawData.value / maxComparationValue) * 100
        statusBackgroundNode.style.flexBasis = ASDimensionMake("\(calculation)%")
        
        style.preferredSize = calculatedSize
        transitionLayout(withAnimation: true, shouldMeasureAsync: false, measurementCompletion: nil)
        isDoneAnimation = true
    }
    
    internal func resetAnimation() {
        statusBackgroundNode.style.flexBasis = ASDimensionMake(0)
        statusValueTextNode.attributedText = NSAttributedString(string: "\(defaultValueStatus)", attributes: [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold),
        NSAttributedString.Key.foregroundColor: UIColor.blackPallete])
        
        style.preferredSize = calculatedSize
        transitionLayout(withAnimation: false, shouldMeasureAsync: false, measurementCompletion: { [weak self] in
            //remove if its still exist
            if self?.displayLink != nil {
                self?.displayLink?.remove(from: .current, forMode: .common)
                self?.displayLink?.invalidate()
                self?.displayLink = nil
            }
        })
        isDoneAnimation = false
    }
    
    private func setupDisplayLink() {
        // Make sure CADisplay link added to main thread, and the selector called from main thread
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.startAnimationDate = Date()
            
            let link = CADisplayLink(target: self, selector: #selector(self.handleAnimationStatusText))
            link.add(to: .current, forMode: .common)
            self.displayLink = link
        }
    }
    
    @objc private func handleAnimationStatusText() {
        let nowAnimationDate = Date()
        let elapsedTime = nowAnimationDate.timeIntervalSince(startAnimationDate)
        
        if elapsedTime >= animationDuration {
            let value = Int(statusRawData.value)
            statusValueTextNode.attributedText = NSAttributedString(string: "\(value)", attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold),
            NSAttributedString.Key.foregroundColor: UIColor.blackPallete])
            
            displayLink?.remove(from: .current, forMode: .common)
            displayLink?.invalidate()
            displayLink = nil
        } else {
            let percentage = elapsedTime / animationDuration
            let value = Int(Double(defaultValueStatus) + percentage * Double(Int(statusRawData.value) - defaultValueStatus))
            statusValueTextNode.attributedText = NSAttributedString(string: "\(value)", attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold),
            NSAttributedString.Key.foregroundColor: UIColor.blackPallete])
        }
        
        transitionLayout(withAnimation: true, shouldMeasureAsync: false, measurementCompletion: nil)
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }    
}

internal struct PokemonStatus {
    let title: String
    let value: CGFloat
}

