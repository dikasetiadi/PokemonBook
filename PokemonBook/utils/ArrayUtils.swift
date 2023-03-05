//
//  ArrayUtils.swift
//  PokemonBook
//
//  Created by andhika.setiadi on 05/03/23.
//  Copyright © 2023 dikasetiadi. All rights reserved.
//

import Foundation

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
