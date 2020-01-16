//
//  EvolutionPokemonViewController.swift
//  PokemonBook
//
//  Created by Nakama on 13/01/20.
//  Copyright © 2020 dikasetiadi. All rights reserved.
//

import AsyncDisplayKit

internal class EvolutionPokemonViewController: ASViewController<ASScrollNode> {
    private let rootNode: ASScrollNode = {
        let node = ASScrollNode()
        node.automaticallyManagesContentSize = true
        node.automaticallyManagesSubnodes = true
        node.backgroundColor = .white
        
        return node
    }()
    
    private lazy var titleTextNode: ASTextNode = {
        let node = ASTextNode()
        let textString = NSAttributedString(string: "Evolution Chain", attributes: [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .bold),
        NSAttributedString.Key.foregroundColor: UIColor.blackPallete])
        node.attributedText = textString
        
        return node
    }()
    
    private lazy var evolutionChainNode: ASDisplayNode = {
        let node = ASDisplayNode()
        node.automaticallyManagesSubnodes = true
        
        return node
    }()
    
    private lazy var emptyStateNode: ASDisplayNode = {
        let node = ASDisplayNode()
        node.automaticallyManagesSubnodes = true

        let logoNode = ASImageNode()
        logoNode.image = #imageLiteral(resourceName: "pokeball")
        logoNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(UIColor.blackPallete.withAlphaComponent(0.12))
        logoNode.style.preferredSize = CGSize(width: 150, height: 150)
        logoNode.contentMode = .scaleAspectFit
        
        let emptyTextNode = ASTextNode2()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let textString = NSAttributedString(string: "Whooa, Looks like this pokemon is not having any evolution...", attributes: [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .bold),
        NSAttributedString.Key.foregroundColor: UIColor.blackPallete,
        NSAttributedString.Key.paragraphStyle: paragraphStyle])
        emptyTextNode.attributedText = textString
        
        node.layoutSpecBlock = { _,_ in
            let contentStack = ASStackLayoutSpec.vertical()
            contentStack.alignItems = .center
            contentStack.justifyContent = .center
            contentStack.spacing = 24
            contentStack.children = [
                logoNode,
                emptyTextNode
            ]
            
            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0), child: contentStack)
        }
        
        return node
    }()
    
    private var pokemonData: ListPokemonDataDummy
    private var evolutionChainWrapper: ASDisplayNode? = nil
    
    init(data: ListPokemonDataDummy) {
        pokemonData = data
        super.init(node: rootNode)
        
        title = "Evolution"

        setupEvolutionChainUI()
        setupUI()
    }
    
    private func setupUI() {
        rootNode.layoutSpecBlock = { [weak self] _,_ -> ASLayoutSpec in
            guard let self = self else { return ASLayoutSpec() }
            
            var alignItemStyle: ASStackLayoutAlignItems = .start
            
            let evolutionData = self.pokemonData.evolveArr
            if let data = evolutionData, data.count <= 1 {
                alignItemStyle = .center
            }
            
            let stack = ASStackLayoutSpec.vertical()
            stack.alignItems = alignItemStyle
            stack.justifyContent = .start
            stack.spacing = 24
            stack.style.width = ASDimensionMake("100%")
            
            if let evoNode = self.evolutionChainWrapper, let data = evolutionData, data.count > 1 {
                stack.children?.append(self.titleTextNode)
                stack.children?.append(evoNode)
            } else {
                // here we set empty state
                stack.children?.append(self.emptyStateNode)
            }
            
            let inset = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16), child: stack)
            
            return ASWrapperLayoutSpec(layoutElement: inset)
        }
    }

    private func setupEvolutionChainUI() {
        guard let evolutionData = pokemonData.evolveArr, evolutionData.count > 1 else {
            return
        }
        
        let rowNode = ASDisplayNode()
        rowNode.automaticallyManagesSubnodes = true
        
        var nodeArr: [ASDisplayNode] = []
        
        for (idx, _) in evolutionData.enumerated() {
            if (idx + 1) < evolutionData.count {
                let isNeedUsingSeparator = (idx + 1) < (evolutionData.count - 1)
                let node = generateRowEvolutionChainNode(from: evolutionData[idx], to: evolutionData[idx + 1], withSeparator: isNeedUsingSeparator)
                
                nodeArr.append(node)
            }
        }
        
        rowNode.layoutSpecBlock = { _,_ in
            let contentStack = ASStackLayoutSpec.vertical()
            contentStack.alignItems = .stretch
            contentStack.justifyContent = .start
            contentStack.spacing = 24
            contentStack.children = nodeArr
            
            contentStack.style.width = ASDimensionMake("100%")
            contentStack.style.flexGrow = 1
            contentStack.style.flexShrink = 1
            contentStack.style.flexBasis = ASDimensionMake(.fraction, 1)
            
            return contentStack
        }
        
        evolutionChainWrapper = rowNode
    }
    
    private func generatePokemonEvolutionNode(pokemon: ListPokemonDataDummy) -> ASDisplayNode {
        let node = ASDisplayNode()
        node.automaticallyManagesSubnodes = true
        
        let imageNode = ASNetworkImageNode()
        imageNode.url = URL(string: pokemon.imageurl)
        imageNode.style.preferredSize = CGSize(width: 76, height: 76)
        imageNode.contentMode = .scaleAspectFit
        
        let logoNode = ASImageNode()
        logoNode.image = #imageLiteral(resourceName: "pokeball")
        logoNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(UIColor.blackPallete.withAlphaComponent(0.05))
        logoNode.style.preferredSize = CGSize(width: 83, height: 83)
        logoNode.contentMode = .scaleAspectFit
        
        let nameNode = ASTextNode()
        nameNode.attributedText = NSAttributedString(string: pokemon.name, attributes: [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold),
        NSAttributedString.Key.foregroundColor: UIColor.blackPallete])
        
        node.layoutSpecBlock = { _,_ in
            let stackImage = ASOverlayLayoutSpec(child: logoNode, overlay: ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: imageNode))
            
            let stackContent = ASStackLayoutSpec.vertical()
            stackContent.spacing = 8
            stackContent.alignItems = .center
            stackContent.justifyContent = .center
            stackContent.children = [
                stackImage,
                nameNode
            ]
            
            return stackContent
        }
        
        return node
    }
    
    private func generateRowEvolutionChainNode(from fromPokemon: ListPokemonDataDummy, to toPokemon: ListPokemonDataDummy, withSeparator: Bool = false) -> ASDisplayNode {
        let node = ASDisplayNode()
        node.automaticallyManagesSubnodes = true
        
        let fromEvolution = generatePokemonEvolutionNode(pokemon: fromPokemon)
        let toEvolution = generatePokemonEvolutionNode(pokemon: toPokemon)
        
        let separatorNode = ASDisplayNode()
        separatorNode.style.width = ASDimensionMake("100%")
        separatorNode.style.height = ASDimensionMake(1)
        separatorNode.backgroundColor = .lightGreyPallete
        
        let toArrowNode = ASImageNode()
        toArrowNode.image = #imageLiteral(resourceName: "arrowRight")
        toArrowNode.contentMode = .scaleAspectFit
        toArrowNode.style.preferredSize = CGSize(width: 22, height: 12)
        
        let levelRequired = ASTextNode2()
        let levelUpReason = toPokemon.reason
        let endIndexReason = levelUpReason.index(levelUpReason.endIndex, offsetBy: -1)
        let range = levelUpReason.index(after: levelUpReason.startIndex)..<endIndexReason
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        levelRequired.attributedText = NSAttributedString(string: String(levelUpReason[range]), attributes: [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .bold),
        NSAttributedString.Key.foregroundColor: UIColor.blackPallete,
        NSAttributedString.Key.paragraphStyle: paragraphStyle])
            
        node.layoutSpecBlock = { _,_ in
            let reasonStack = ASStackLayoutSpec.vertical()
            reasonStack.alignItems = .center
            reasonStack.justifyContent = .center
            reasonStack.spacing = 8
            reasonStack.children = [
                toArrowNode,
                levelRequired
            ]
            reasonStack.style.flexGrow = 1
            reasonStack.style.flexShrink = 1
            reasonStack.style.flexBasis = ASDimensionMake(.fraction, 1)
            
            let rowStack = ASStackLayoutSpec.horizontal()
            rowStack.alignItems = .center
            rowStack.justifyContent = .spaceAround
            rowStack.children = [
                fromEvolution,
                reasonStack,
                toEvolution
            ]
            rowStack.style.flexGrow = 1
            rowStack.style.flexShrink = 1
            rowStack.style.flexBasis = ASDimensionMake(.fraction, 1)
            
            let contentStack = ASStackLayoutSpec.vertical()
            contentStack.spacing = 24
            contentStack.children = [
                rowStack
            ]
            contentStack.style.flexGrow = 1
            contentStack.style.flexShrink = 1
            contentStack.style.flexBasis = ASDimensionMake(.fraction, 1)
            
            if withSeparator {
                contentStack.children?.append(separatorNode)
            }
            
            return contentStack
        }
        
        
        return node
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
