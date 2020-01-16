//
//  DeviceUtils.swift
//  PokemonBook
//
//  Created by Nakama on 10/01/20.
//  Copyright © 2020 dikasetiadi. All rights reserved.
//

import Foundation
import UIKit

public struct Device {
    // iDevice detection code
    public static let IS_IPAD = UIDevice.current.userInterfaceIdiom == .pad
    public static let IS_IPHONE = UIDevice.current.userInterfaceIdiom == .phone
    public static let HAS_PHYSICAL_HOME_BUTTON = { () -> Bool in
        if #available(iOS 11.0, *),
            let keyWindow = UIApplication.shared.keyWindow,
            keyWindow.responds(to: #selector(getter: keyWindow.safeAreaInsets)),
            keyWindow.safeAreaInsets.bottom > 0 {
            return false
        } else {
            return true
        }
    }()

    public static let IS_RETINA = UIScreen.main.scale >= 2.0

    public static let SCREEN_WIDTH = Int(UIScreen.main.bounds.size.width)
    public static let SCREEN_HEIGHT = Int(UIScreen.main.bounds.size.height)
    public static let SCREEN_MAX_LENGTH = Int(max(SCREEN_WIDTH, SCREEN_HEIGHT))
    public static let SCREEN_MIN_LENGTH = Int(min(SCREEN_WIDTH, SCREEN_HEIGHT))

    public static let IS_IPHONE_4_OR_LESS = IS_IPHONE && SCREEN_MAX_LENGTH < 568
    public static let IS_IPHONE_5 = IS_IPHONE && SCREEN_MAX_LENGTH == 568
    public static let IS_IPHONE_6 = IS_IPHONE && SCREEN_MAX_LENGTH == 667
    public static let IS_IPHONE_6P = IS_IPHONE && SCREEN_MAX_LENGTH == 736
    public static let IS_IPHONE_X = IS_IPHONE && SCREEN_MAX_LENGTH == 812
}
