//
//  HorizontalListPokemonViewController.swift
//  PokemonBook
//
//  Created by Nakama on 31/12/19.
//  Copyright © 2019 dikasetiadi. All rights reserved.
//

import Foundation
import AsyncDisplayKit

public class HorizontalListPokemonViewController: ASViewController<ASCollectionNode> {
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
    
    public init() {
        super.init(node: rootNode)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        rootNode.delegate = self
        rootNode.dataSource = self
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.fetchDataLocal()
        }
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
        
        //dont know how the best practice to fill the data
        //use old ways :(
        //to populate data evolves
        for (idx, dataPokemon) in dataPokemonDummy.enumerated() {
            let nowDataEvolutions = dataPokemon.evolutions
            
            // here we handle the evolutions arr data
            var newArrEvolutions: [ListPokemonDataDummy] = []
            for evolutionID in nowDataEvolutions {
                let range = evolutionID.index(after: evolutionID.startIndex)..<evolutionID.endIndex
                if let intID = Int(evolutionID[range]), intID <= dataPokemonDummy.count {
                    // we -1 because index always start from 0
                    newArrEvolutions.append(dataPokemonDummy[intID - 1])
                }
            }
            //we fill
            dataPokemonDummy[idx].evolveArr = newArrEvolutions

            // here we handle the evolutions from data
            let pokemonEvolveFromID = dataPokemon.evolvedfrom
            if pokemonEvolveFromID.count > 0 {
                let range = pokemonEvolveFromID.index(after: pokemonEvolveFromID.startIndex)..<pokemonEvolveFromID.endIndex
                if let intID = Int(pokemonEvolveFromID[range]), intID <= dataPokemonDummy.count {
                    // we -1 because index always start from 0
                    dataPokemonDummy[idx].evolvedFromData?.append(dataPokemonDummy[intID - 1])
                }
            }
        }
        
        isLoading = false
        rootNode.reloadData { [weak self] in
            guard let self = self else { return }
            
            self.setBackgroundBase()
        }
    }
    
    private func updateDataLimit() {
        numberOfData += 10
        rootNode.reloadData()
    }
    
    internal func setBackgroundBase() {
        var visibleRect = CGRect()
        visibleRect.origin = rootNode.contentOffset
        visibleRect.size = rootNode.bounds.size
        
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let indexPath = rootNode.indexPathForItem(at: visiblePoint) else { return }
        
        let bgColor = whichBackgroundColor(idx: indexPath)
        
        UIView.animate(withDuration: 0.24) { [weak self] in
            self?.rootNode.backgroundColor = bgColor
        }
    }
    
    private func whichBackgroundColor(idx: IndexPath) -> UIColor {
        
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
        var index = 0
        
        if cellsCount > 0 {
            for idx in 0..<cellsCount {
                let itemCell = rootNode.nodeForItem(at: cells[idx])
                if selectedIndexPath != cells[idx] {
                    if selectedIndexPath != cells[idx] {
                        UIView.animate(withDuration: 0.3, delay: 0.15 * Double(idx), options: [], animations: {
                            itemCell?.alpha = 1
                            itemCell?.view.transform = .identity
                        }, completion: nil)
                    }
                    index += 1
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
        var index = 0
        
        if cellsCount > 0 {
            for idx in 0..<cellsCount {
                let itemCell = rootNode.nodeForItem(at: cells[idx])
                if selectedIndexPath != cells[idx] {
                    if selectedIndexPath != cells[idx] {
                        UIView.animate(withDuration: 0.2, delay: 0.15 * Double(idx), options: [], animations: {
                            itemCell?.alpha = 0
                            itemCell?.view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                        }, completion: nil)
                    }
                    index += 1
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
        var cell: ASCellNode = PlaceholderCell()
        
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
        
        if isLoading {
            /* shimmering logic */
            if let cellNode = node as? PlaceholderCell {
                cellNode.startAnimation()
            }
        } else {
            /* load more logic */
            guard let indexPath = rootNode.indexPath(for: node) else { return }
            
            if indexPath.row == numberOfData - 1 {
                updateDataLimit()
            }
            
            if let cellNode = node as? PokemonHorizontalCell {
                cellNode.showLogo()
            }
        }
    }
        
    public func collectionNode(_ collectionNode: ASCollectionNode, didEndDisplayingItemWith node: ASCellNode) {
        
        guard isLoading else { return }

        if let cellNode = node as? PlaceholderCell {
            cellNode.stopAnimation()
        }
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
