//
//  PushAnimator.swift
//  PokemonBook
//
//  Created by Nakama on 06/01/20.
//  Copyright © 2020 dikasetiadi. All rights reserved.
//

import UIKit
import AsyncDisplayKit

internal class PushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 2.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        
        guard let fromVC = transitionContext.viewController(forKey: .from) as? AnimateAbleProtocol,
            let toVC = transitionContext.viewController(forKey: .to) as? AnimateAbleProtocol else {
                transitionContext.completeTransition(false)
                return
        }
        
        let fromViewController = transitionContext.viewController(forKey: .from)!
        fromViewController.view.backgroundColor = UIColor.clear
        
        let toViewController = transitionContext.viewController(forKey: .to)!
        
        let imageViewSnapshot = UIImageView(image: fromVC.cellImageView.image)
        imageViewSnapshot.contentMode = .scaleAspectFit
        
        // Background View With Correct Color
        let backgroundView = UIView()
        backgroundView.frame = fromVC.backgroundColor.frame
        backgroundView.backgroundColor = fromVC.backgroundColor.backgroundColor
        containerView.addSubview(backgroundView)
        
        // prepare corner radius animation
        let animationCornerRadius = CABasicAnimation(keyPath: "cornerRadius")
        animationCornerRadius.fromValue = 8
        animationCornerRadius.toValue = 16
        animationCornerRadius.duration = 0.24
        
        // Cell Background
        let cellBackground = UIView()
        cellBackground.frame = containerView.convert(fromVC.cellBackground.frame, from: fromVC.cellBackground.superview)
        cellBackground.backgroundColor = fromVC.cellBackground.backgroundColor
        cellBackground.layer.cornerRadius = fromVC.cellBackground.layer.cornerRadius
        cellBackground.layer.masksToBounds = fromVC.cellBackground.layer.masksToBounds
        
        containerView.addSubview(fromViewController.view)
        containerView.addSubview(toViewController.view)
        
        containerView.addSubview(cellBackground)
        containerView.addSubview(imageViewSnapshot)
        
        fromViewController.view.isHidden = true
        toViewController.view.isHidden = true
        
        // typesView
        var typesViewWithTextFromVC: [UIView] = []
        for (idx, typeView) in fromVC.typesView.enumerated() {
            let newView = UIView()
            newView.frame = containerView.convert(typeView.frame, from: fromVC.cellBackground.superview)
            newView.backgroundColor = typeView.backgroundColor
            newView.layer.cornerRadius = typeView.layer.cornerRadius
            
            let newTextView = UILabel()
            newTextView.text = fromVC.typesTextView[idx].text
            newTextView.font = fromVC.typesTextView[idx].font
            newTextView.textColor = fromVC.typesTextView[idx].textColor
            newTextView.frame = typeView.subviews[0].frame
            
            newView.addSubview(newTextView)
            typesViewWithTextFromVC.append(newView)
            
            containerView.addSubview(newView)
        }
        
        var typesViewWithTextToVC: [UIView] = []
        for (idx, typeView) in toVC.typesView.enumerated() {
            let newView = UIView()
            newView.frame = containerView.convert(typeView.frame, from: toVC.cellBackground.superview)
            newView.backgroundColor = typeView.backgroundColor
            newView.layer.cornerRadius = typeView.layer.cornerRadius
            newView.layer.shadowColor = typeView.layer.shadowColor
            newView.layer.shadowOffset = typeView.layer.shadowOffset
            newView.layer.shadowOpacity = typeView.layer.shadowOpacity
            newView.layer.shadowRadius = typeView.layer.shadowRadius
            
            let newTextView = UILabel()
            newTextView.text = toVC.typesTextView[idx].text
            newTextView.font = toVC.typesTextView[idx].font
            newTextView.textColor = toVC.typesTextView[idx].textColor
            newTextView.frame = typeView.subviews[0].frame
            
            newView.addSubview(newTextView)
            typesViewWithTextToVC.append(newView)
        }
        
        // big name Text fromVC
        let newTextViewFromVC = UILabel()
        newTextViewFromVC.text = fromVC.nameTextView.text
        newTextViewFromVC.font = fromVC.nameTextView.font
        newTextViewFromVC.textColor = fromVC.nameTextView.textColor
        newTextViewFromVC.frame = containerView.convert(fromVC.nameTextView.frame, from: fromVC.cellBackground.superview)
        
        // big name Text toVC
        let newTextViewToVC = UILabel()
        newTextViewToVC.text = toVC.nameTextView.text
        newTextViewToVC.font = toVC.nameTextView.font
        newTextViewToVC.textColor = toVC.nameTextView.textColor
        newTextViewToVC.frame = containerView.convert(toVC.nameTextView.frame, from: toVC.cellBackground.superview)
        
        containerView.addSubview(newTextViewFromVC)
        
        imageViewSnapshot.frame = containerView.convert(fromVC.cellImageView.frame, from: fromVC.cellBackground.superview)
        
        let frameAnim1 = CGRect(x: 0, y: cellBackground.frame.origin.y, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        let frameAnim2 = CGRect(x: 0, y: toVC.cellBackground.frame.origin.y, width: toVC.cellBackground.frame.maxX, height: toVC.cellBackground.frame.maxY)
        
        
        let animator1 = {
            UIViewPropertyAnimator(duration: 0.2, dampingRatio: 0.9) {
                cellBackground.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }
        }()
        
        let animator2 = {
            UIViewPropertyAnimator(duration: 0.3, dampingRatio: 0.9) {
                cellBackground.layer.cornerRadius = 16
                cellBackground.frame = frameAnim1
            }
        }()
        
        let animator3 = {
            UIViewPropertyAnimator(duration: 0.2, dampingRatio: 1.4) {
                for (idx, toView) in typesViewWithTextToVC.enumerated() {
                    typesViewWithTextFromVC[idx].frame = toView.frame
                    typesViewWithTextFromVC[idx].backgroundColor = toView.backgroundColor
                }
                
                newTextViewFromVC.frame = newTextViewToVC.frame
                
                UIView.transition(with: newTextViewFromVC, duration: 0.7, options: .transitionCrossDissolve, animations: {
                    newTextViewFromVC.font = newTextViewToVC.font
                    newTextViewFromVC.textColor = newTextViewToVC.textColor
                }, completion: nil)
                
                cellBackground.frame = frameAnim2
                imageViewSnapshot.frame = containerView.convert(toVC.cellImageView.frame, from: toVC.cellBackground.superview)
                
                for (idx, toView) in typesViewWithTextToVC.enumerated() {
                    typesViewWithTextFromVC[idx].layer.shadowColor = toView.layer.shadowColor
                    typesViewWithTextFromVC[idx].layer.shadowOffset = toView.layer.shadowOffset
                    typesViewWithTextFromVC[idx].layer.shadowOpacity = toView.layer.shadowOpacity
                    typesViewWithTextFromVC[idx].layer.shadowRadius = toView.layer.shadowRadius
                }
            }
        }()
        
        
        animator1.addCompletion { _ in
            animator2.startAnimation()
            cellBackground.layer.add(animationCornerRadius, forKey: "cornerRadius")
        }
        
        animator2.addCompletion {  _ in
            animator3.startAnimation(afterDelay: 0.1)
        }
        
        
        animator3.addCompletion {  _ in
            backgroundView.removeFromSuperview()
            imageViewSnapshot.removeFromSuperview()
            cellBackground.layer.removeAllAnimations()
            cellBackground.removeFromSuperview()
            newTextViewFromVC.removeFromSuperview()
            
            for thisView in typesViewWithTextFromVC {
                thisView.removeFromSuperview()
            }
            
            fromViewController.view.removeFromSuperview()
            
            toViewController.view.isHidden = false
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
        animator1.startAnimation()
    }
}
