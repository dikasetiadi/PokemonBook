//
//  TransitionCoordinator.swift
//  PokemonBook
//
//  Created by Nakama on 06/01/20.
//  Copyright © 2020 dikasetiadi. All rights reserved.
//

import UIKit

internal class TransitionCoordinator: NSObject, UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            return PushAnimator()
        case .pop:
            return PopAnimator()
        default:
            return nil
        }
    }
}
