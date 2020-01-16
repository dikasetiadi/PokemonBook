//
//  HorizontalListFlowLayout.swift
//  PokemonBook
//
//  Created by Nakama on 02/01/20.
//  Copyright © 2020 dikasetiadi. All rights reserved.
//

import Foundation
import UIKit

internal class HorizontalListFlowLayout: UICollectionViewFlowLayout {
    // for now we rely on screen size, after we get how to adapt responsive in split screen (ipad)
    // we will change this calculation
    private let cellSize = CGSize(width: UIScreen.main.bounds.width - 48, height: 300)
    private var contentInsetLeft: CGFloat = 16
    private var contentInsetRight: CGFloat = 16
    
    override init() {
        super.init()
        
        scrollDirection = .horizontal
        itemSize = cellSize
        // to make only one row scrolling horizontal
        minimumInteritemSpacing = .greatestFiniteMagnitude
        minimumLineSpacing = 16
        // give content inset on collectionView wrapper
        sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        super.prepare()
                
        if let collectionView = collectionView {
            collectionView.decelerationRate = .fast
            // give inset on each cell collectionView
            collectionView.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        }
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let width = cellSize.width + minimumLineSpacing
        var newOffset: CGPoint = .zero
        var offset = proposedContentOffset.x + (contentInsetLeft + contentInsetRight)
        
        if velocity.x > 0 {
            offset = width * ceil(offset / width)
        } else if velocity.x == 0 {
            offset = width * round(offset / width)
        } else {
            offset = width * floor(offset / width)
        }
        
        newOffset.x = offset - contentInsetLeft
        newOffset.y = proposedContentOffset.y
        
        return newOffset
    }
}
