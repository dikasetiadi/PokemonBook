//
//  PopAnimator.swift
//  PokemonBook
//
//  Created by Nakama on 06/01/20.
//  Copyright © 2020 dikasetiadi. All rights reserved.
//

import UIKit

internal class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    
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
        toViewController.view.backgroundColor = toVC.backgroundColor.backgroundColor
        containerView.backgroundColor = toVC.backgroundColor.backgroundColor
        
        let imageViewSnapshot = UIImageView(image: fromVC.cellImageView.image)
        imageViewSnapshot.contentMode = .scaleAspectFit
        imageViewSnapshot.frame = containerView.convert(fromVC.cellImageView.frame, from: fromVC.cellBackground.superview)
        
        // prepare corner radius animation
        let animationCornerRadius = CABasicAnimation(keyPath: "cornerRadius")
        animationCornerRadius.fromValue = 16
        animationCornerRadius.toValue = 8
        animationCornerRadius.duration = 0.24
        
        //Background View With Correct Color
        let backgroundView = UIView()
        backgroundView.frame = fromVC.backgroundColor.frame
        backgroundView.backgroundColor = fromVC.backgroundColor.backgroundColor
        
        // Cell Background
        let cellBackground = UIView()
        cellBackground.frame = fromVC.cellBackground.frame
        cellBackground.backgroundColor = fromVC.cellBackground.backgroundColor
        cellBackground.layer.cornerRadius = 16
        
        containerView.addSubview(toViewController.view)
        containerView.addSubview(cellBackground)
        containerView.addSubview(imageViewSnapshot)
        
        fromViewController.view.isHidden = true
        toViewController.view.isHidden = true
        
        var cellBackgroundToVC: CGRect
        var frameImageToVC: CGRect
        
        if #available(iOS 11.0, *) {
            // use the normal way
            cellBackgroundToVC = containerView.convert(toVC.cellBackground.frame, from: toVC.cellBackground.superview)
            frameImageToVC = containerView.convert(toVC.cellImageView.frame, from: toVC.cellBackground.superview)
        } else {
            // still dont know why this happen on only iOS 10, weird?
            // in this version OS, need to store frame from layoutAttributes (in cellLastRect)

            cellBackgroundToVC = containerView.convert(toVC.cellBackground.frame, from: toVC.cellBackground.superview)
            
            if let newPos = toVC.cellLastRect {
                cellBackgroundToVC.origin.y = newPos.origin.y
            }
            
            frameImageToVC = CGRect(x: toVC.cellImageView.frame.origin.x + cellBackgroundToVC.origin.x, y: toVC.cellImageView.frame.origin.y + cellBackgroundToVC.origin.y, width: toVC.cellImageView.frame.size.width, height: toVC.cellImageView.frame.size.height)
        }
        
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
            
            if #available(iOS 11.0, *) {
                // do nothing because the calculation already right!
            } else {
                newView.frame.origin.y = typeView.frame.origin.y + cellBackgroundToVC.origin.y
            }
            
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
        
        if #available(iOS 11.0, *) {
            // do nothing because the calculation already right!
        } else {
            newTextViewToVC.frame.origin.y = toVC.nameTextView.frame.origin.y + cellBackgroundToVC.origin.y
        }
        
        let imageViewToVC = containerView.convert(toVC.cellImageView.frame, from: toVC.cellBackground.superview)
        
        let frameAnim1 = CGRect(x: fromVC.cellBackground.frame.minX, y: cellBackgroundToVC.origin.y, width: UIScreen.main.bounds.width, height: cellBackgroundToVC.height)
        let frameAnim2 = CGRect(x: cellBackgroundToVC.origin.x, y: cellBackgroundToVC.origin.y, width: cellBackgroundToVC.width, height: cellBackgroundToVC.height )
        
        let animator1 = {
            UIViewPropertyAnimator(duration: 0.3, curve: .easeOut) {
                cellBackground.frame = frameAnim1
                for (idx, toView) in typesViewWithTextToVC.enumerated() {
                    typesViewWithTextFromVC[idx].frame = toView.frame
                    typesViewWithTextFromVC[idx].backgroundColor = toView.backgroundColor
                    typesViewWithTextFromVC[idx].layer.shadowColor = toView.layer.shadowColor
                    typesViewWithTextFromVC[idx].layer.shadowOffset = toView.layer.shadowOffset
                    typesViewWithTextFromVC[idx].layer.shadowOpacity = toView.layer.shadowOpacity
                    typesViewWithTextFromVC[idx].layer.shadowRadius = toView.layer.shadowRadius
                }
                
                newTextViewFromVC.frame = newTextViewToVC.frame
                
                UIView.transition(with: newTextViewFromVC, duration: 0.7, options: .transitionCrossDissolve, animations: {
                    newTextViewFromVC.font = newTextViewToVC.font
                    newTextViewFromVC.textColor = newTextViewToVC.textColor
                }, completion: nil)
            }
        }()
        
        let animator2 = {
            UIViewPropertyAnimator(duration: 0.3, curve: .easeOut) {
                imageViewSnapshot.frame = CGRect(x: frameImageToVC.minX, y: cellBackgroundToVC.minY - (toVC.cellImageView.frame.height / 2) , width: imageViewToVC.width, height: imageViewToVC.height)
            }
        }()
        
        let animator3 = {
            UIViewPropertyAnimator(duration: 0.35, dampingRatio: 0.6) {
                cellBackground.frame = frameAnim2
                cellBackground.layer.cornerRadius = 8
                
                imageViewSnapshot.frame = frameImageToVC
                
            }
        }()
        
        
        // Animations Completion Handler
        animator1.addCompletion {  _ in
            animator3.startAnimation()
            cellBackground.layer.add(animationCornerRadius, forKey: "cornerRadius")
        }
        
        animator3.addCompletion { _ in
            backgroundView.removeFromSuperview()
            imageViewSnapshot.removeFromSuperview()
            cellBackground.layer.removeAllAnimations()
            cellBackground.removeFromSuperview()
            newTextViewFromVC.removeFromSuperview()
            
            for thisView in typesViewWithTextFromVC {
                thisView.removeFromSuperview()
            }
            
            UIView.animate(withDuration: 0.24, animations: {
                toViewController.view.isHidden = false
            }, completion: { (finished) in
                if finished {
                    containerView.backgroundColor = .clear
                    transitionContext.completeTransition(true)
                }
            })
        }
        
        animator1.startAnimation()
        animator2.startAnimation()
    }
    
}
