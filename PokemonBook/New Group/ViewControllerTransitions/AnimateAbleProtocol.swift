//
//  AnimateAbleProtocol.swift
//  PokemonBook
//
//  Created by Nakama on 06/01/20.
//  Copyright © 2020 dikasetiadi. All rights reserved.
//

import UIKit

@objc public protocol AnimateAbleProtocol {
    var cellImageView: UIImageView { get }
    var backgroundColor: UIView { get }
    var cellBackground: UIView { get }
    var nameTextView: UILabel { get }
    var typesView: [UIView] { get set }
    var typesTextView: [UILabel] { get set }
    @objc optional var cellLastRect: CGRect { get }
}
