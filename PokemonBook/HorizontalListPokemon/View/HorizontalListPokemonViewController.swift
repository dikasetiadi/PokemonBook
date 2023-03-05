//
//  HorizontalListPokemonViewController.swift
//  PokemonBook
//
//  Created by Nakama on 31/12/19.
//  Copyright © 2019 dikasetiadi. All rights reserved.
//

import Foundation
import AsyncDisplayKit

public class HorizontalListPokemonViewController: ASDKViewController<ASCollectionNode> {
    private var numberOfData: Int = 10
    private var dataPokemonDummy: [ListPokemonDataDummy] = []
    private var isLoading: Bool = true
    private var selectedIndexPath: IndexPath? = nil
    private var selectedBackgroundColor: UIColor? = .white
    private var selectedTypesView: [UIView] = []
    private var selectedTypesTextView: [UILabel] = []
    
    private let transition = TransitionCoordinator()
    
    private let rootNode: ASCollectionNode = {
        let layout = HorizontalListFlowLayout()
        
        let node = ASCollectionNode(collectionViewLayout: layout)
        node.backgroundColor = .white
        node.showsHorizontalScrollIndicator = false
        
        return node
    }()
    
    public override init() {
        super.init(node: rootNode)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        rootNode.delegate = self
        rootNode.dataSource = self

        fetchDataLocal()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let transitionCoord = navigationController?.transitionCoordinator,
            let fromVC = transitionCoord.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionCoord.viewController(forKey: UITransitionContextViewControllerKey.to),
            fromVC is DetailPokemonViewController,
            toVC is HorizontalListPokemonViewController {
            
            animationFadeIn()
        }
    }
    
    // get JSON data local file
    private func fetchDataLocal() {
        
        dataPokemonDummy = loadFromBundle("PokemonData")
        
        /// here we need to loop manually,
        /// because we have to setup data for evolution chain data UI
        ///
        for (idx, dataPokemon) in dataPokemonDummy.enumerated() {
            let nowDataEvolutions = dataPokemon.evolutions
            
            // here we handle the evolutions arr data
            var newArrEvolutions: [ListPokemonDataDummy] = []
            for evolutionID in nowDataEvolutions {
                /// we want to make sure only give the right array to render evolution chain
                ///
                if var evolutionPokemonData = dataPokemonDummy.first(where: { $0.id == evolutionID }) {
                                       
                    /// check if has any evolved from
                    ///
                    let pokemonEvolveFromID = evolutionPokemonData.evolvedfrom
                    
                    if pokemonEvolveFromID.count > 0,
                       let pokemonEvolvedFromData = dataPokemonDummy.first(where: { $0.id == pokemonEvolveFromID }) {
                        /// we -1 because index always start from 0
                        ///
                        evolutionPokemonData.evolvedFromData = [pokemonEvolvedFromData]
                    } else {
                        evolutionPokemonData.evolvedFromData = nil
                    }
                    
                    newArrEvolutions.append(evolutionPokemonData)
                }
            }
            
            /// we fill all data we prepared before
            ///
            dataPokemonDummy[idx].evolveArr = newArrEvolutions
        }
        
        /// to simulate delay loading while we ready get all the data
        ///
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let self = self else { return }
            
            self.isLoading = false
            self.rootNode.reloadData { [weak self] in
                self?.setBackgroundBase()
            }
        }
    }
    
    private func updateDataLimit() {
        /// make sure we added the correct remaining data
        ///
        let addedNumberData: Int = {
            let countRemainingPokemonData = dataPokemonDummy.count - numberOfData
            
            guard countRemainingPokemonData > 0 else { return 0 }
            
            if countRemainingPokemonData >= 10 {
                return 10
            } else {
                return countRemainingPokemonData
            }
        }()
        
        guard addedNumberData > 0 else { return }
        
        numberOfData += addedNumberData
        rootNode.reloadData()
    }
    
    internal func setBackgroundBase() {
        let visibleRect = CGRect(
            origin: rootNode.contentOffset,
            size: rootNode.bounds.size
        )
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        
        guard let indexPath = rootNode.indexPathForItem(at: visiblePoint) else { return }
        
        let bgColor = whichBackgroundColor(idx: indexPath)
        
        UIView.animate(withDuration: 0.24) { [weak self] in
            self?.rootNode.backgroundColor = bgColor
        }
    }
    
    private func whichBackgroundColor(idx: IndexPath) -> UIColor {
        guard idx.row < dataPokemonDummy.count else { return .lightBluePallete }
        
        let typesArr = dataPokemonDummy[idx.row].typeofpokemon[0].lowercased()
        let bgColor: UIColor
        
        switch typesArr {
        case "grass", "bug" :
            bgColor = .lightTealPallete
        case "fire":
            bgColor = .lightRedPallete
        case "water", "fighting", "normal":
            bgColor = .lightBluePallete
        case "electric", "psychic":
            bgColor = .lightYellowPallete
        case "poison", "ghost":
            bgColor = .lightPurplePallete
        case "ground", "rock":
            bgColor = .lightBrownPallete
        case "dark":
            bgColor = .blackPallete
        default:
            bgColor = .lightBluePallete
        }
        
        return bgColor
    }
    
    private func animationFadeIn() {
        let cells = rootNode.indexPathsForVisibleItems
        let cellsCount = cells.count
        
        if cellsCount > 0 {
            for idx in 0..<cellsCount {
                let itemCell = rootNode.nodeForItem(at: cells[idx])
                if selectedIndexPath != cells[idx] {
                    UIView.animate(
                        withDuration: 0.3,
                        delay: 0.15 * Double(idx),
                        options: [],
                        animations: {
                            itemCell?.alpha = 1
                            itemCell?.view.transform = .identity
                        },
                        completion: nil
                    )
                } else {
                    if let nodeCell = itemCell as? PokemonHorizontalCell {
                        nodeCell.showLogo()
                        nodeCell.isUserInteractionEnabled = true
                    }
                }
            }
        }
    }
    
    private func animationFadeOut() {
        let cells = rootNode.indexPathsForVisibleItems
        let cellsCount = cells.count
        
        if cellsCount > 0 {
            for idx in 0..<cellsCount {
                let itemCell = rootNode.nodeForItem(at: cells[idx])
                if selectedIndexPath != cells[idx] {
                    UIView.animate(
                        withDuration: 0.2,
                        delay: 0.15 * Double(idx),
                        options: [],
                        animations: {
                            itemCell?.alpha = 0
                            itemCell?.view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                        },
                        completion: nil
                    )
                } else {
                    if let nodeCell = itemCell as? PokemonHorizontalCell {
                        nodeCell.hideLogo()
                    }
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension HorizontalListPokemonViewController: ASCollectionDataSource {
    public func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }
    
    public func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        if isLoading {
            return 5
        } else {
            return numberOfData
        }
    }
    
    public func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        guard indexPath.row < dataPokemonDummy.count else { return ASCellNode() }
        
        let cell: ASCellNode
        
        if isLoading {
            cell = PlaceholderCell()
        } else {
            let dataRow = dataPokemonDummy[indexPath.row]
            cell = PokemonHorizontalCell(data: dataRow)
        }
        
        return cell
    }
    
}

extension HorizontalListPokemonViewController: ASCollectionDelegate {
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard !isLoading else { return }
        
        setBackgroundBase()
    }
    
    public func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        if let cell = rootNode.nodeForItem(at: indexPath) as? PokemonHorizontalCell, !isLoading {
            cell.isUserInteractionEnabled = false
            
            selectedIndexPath = indexPath
            
            let detailVC = DetailPokemonViewController()
            
            let imageURL = dataPokemonDummy[indexPath.row].imageurl
            let bgColor = whichBackgroundColor(idx: indexPath)
            
            detailVC.urlImage = imageURL
            detailVC.bgColor = bgColor
            detailVC.pokemonData = dataPokemonDummy[indexPath.row]
            selectedBackgroundColor = bgColor
            
            selectedTypesView = cell.typesViewArr
            selectedTypesTextView = cell.typesTextViewArr
            animationFadeOut()

            navigationController?.delegate = transition
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (Double(rootNode.visibleNodes.count) * 0.1 )) { [weak self] in // change 2 to desired number of seconds
                self?.navigationController?.pushViewController(detailVC, animated: true)
            }
        }
    }
    
    public func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
        /// here we have shimmer animation logic
        ///
        if isLoading {
            if let cellNode = node as? PlaceholderCell {
                cellNode.startAnimation()
            }
        } else {
            if let cellNode = node as? PokemonHorizontalCell {
                cellNode.showLogo()
            }
        }
    }
        
    public func collectionNode(_ collectionNode: ASCollectionNode, didEndDisplayingItemWith node: ASCellNode) {
        guard isLoading,
              let cellNode = node as? PlaceholderCell
        else { return }

        cellNode.stopAnimation()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        /// load more logic
        ///
        guard let lastVisibleIndex = rootNode.indexPathsForVisibleItems.last,
              scrollView.contentOffset.x > 0,
              lastVisibleIndex.row == (numberOfData - 1)
        else { return }
        
        updateDataLimit()
    }
}

extension HorizontalListPokemonViewController: AnimateAbleProtocol {
    public var nameTextView: UILabel {
        if let selectedIndex = selectedIndexPath, let cell = rootNode.nodeForItem(at: selectedIndex) as? PokemonHorizontalCell {
            
            let nameTextLabel = UILabel()
            nameTextLabel.attributedText = cell.pokemonNameNode.attributedText
            nameTextLabel.frame = cell.pokemonNameNode.frame
            return nameTextLabel
        }
        
        return UILabel()
    }
    
    public var typesTextView: [UILabel] {
        get {
            return selectedTypesTextView
        }
        set {
            selectedTypesTextView = newValue
        }
    }
    
    public var typesView: [UIView] {
        get {
            return selectedTypesView
        }
        set {
            selectedTypesView = newValue
        }
    }
    
    public var cellImageView: UIImageView {
        if let selectedIndex = selectedIndexPath, let cell = rootNode.nodeForItem(at: selectedIndex) as? PokemonHorizontalCell {
            
            let imgView = UIImageView()
            imgView.frame = cell.pokemonImageNode.frame
            imgView.image = cell.pokemonImageNode.image
            
            return imgView
        }
        
        return UIImageView()
    }
    
    public var backgroundColor: UIView {
        let view = UIView()
        view.frame = rootNode.view.frame
        view.backgroundColor = selectedBackgroundColor
        
        return view
    }
    
    public var cellBackground: UIView {
        if let selectedIndex = selectedIndexPath, let cell = rootNode.nodeForItem(at: selectedIndex) as? PokemonHorizontalCell {
            return cell.view
        }
        
        return UIView()
    }
    
    
    public var cellLastRect: CGRect {
        if let selectedIndex = selectedIndexPath, let cellInfoRect = rootNode.view.layoutAttributesForItem(at: selectedIndex) {
             return cellInfoRect.frame
        }
        
        return .zero
    }
}
