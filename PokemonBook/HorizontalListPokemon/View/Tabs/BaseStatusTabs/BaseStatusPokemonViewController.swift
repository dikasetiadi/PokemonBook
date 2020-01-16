//
//  BaseStatusPokemonViewController.swift
//  PokemonBook
//
//  Created by Nakama on 13/01/20.
//  Copyright © 2020 dikasetiadi. All rights reserved.
//

import AsyncDisplayKit

internal class BaseStatusPokemonViewController: ASViewController<ASScrollNode> {
    private let rootNode: ASScrollNode = {
        let node = ASScrollNode()
        node.automaticallyManagesContentSize = true
        node.automaticallyManagesSubnodes = true
        node.backgroundColor = .white
        
        return node
    }()
    
    private var pokemonData: ListPokemonDataDummy
    private var weaknessGroupNode: ASDisplayNode? = nil
    private var statusGroupNode: [ASDisplayNode] = []
    
    init(data: ListPokemonDataDummy) {
        pokemonData = data
        super.init(node: rootNode)
        
        title = "Base Stats"
        
        setupStatusInfoGroupNode()
        setupWeaknessGroupNodeUI()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        for statusNode in statusGroupNode {
            if let node = statusNode as? BaseStatusNode {
                node.startAnimation()
            }
        }
    }
    
    private func setupUI() {
        rootNode.layoutSpecBlock = { [weak self] _,_ -> ASLayoutSpec in
            guard let self = self else { return ASLayoutSpec() }
            
            let stack = ASStackLayoutSpec.vertical()
            stack.alignItems = .start
            stack.justifyContent = .start
            stack.spacing = 24
            stack.style.width = ASDimensionMake("100%")

            if self.statusGroupNode.count > 0 {
                for node in self.statusGroupNode {
                    stack.children?.append(node)
                }
            }
            
            if let node = self.weaknessGroupNode {
                stack.children?.append(node)
            }
                        
            let inset = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16), child: stack)
            
            return ASWrapperLayoutSpec(layoutElement: inset)
        }
    }
    
    private func setupStatusInfoGroupNode() {
        let hpNode = generateStatusInfoNode(data: PokemonStatus(title: "HP", value: CGFloat(pokemonData.hp)))
        let attackNode = generateStatusInfoNode(data: PokemonStatus(title: "Attack", value: CGFloat(pokemonData.attack)))
        let defenseNode = generateStatusInfoNode(data: PokemonStatus(title: "Defense", value: CGFloat(pokemonData.defense)))
        let spAttackNode = generateStatusInfoNode(data: PokemonStatus(title: "Sp. Atk", value: CGFloat(pokemonData.special_attack)))
        let spDefenseNode = generateStatusInfoNode(data: PokemonStatus(title: "Sp. Def", value: CGFloat(pokemonData.special_defense)))
        let speedNode = generateStatusInfoNode(data: PokemonStatus(title: "Speed", value: CGFloat(pokemonData.speed)))
        let totalNode = generateStatusInfoNode(data: PokemonStatus(title: "Total", value: CGFloat(pokemonData.total)), maxComparationValue: 400)
        
        statusGroupNode = [
            hpNode,
            attackNode,
            defenseNode,
            spAttackNode,
            spDefenseNode,
            speedNode,
            totalNode
        ]
    }
    
    private func generateStatusInfoNode(data: PokemonStatus, maxComparationValue: CGFloat = 100) -> ASDisplayNode {
        let node = BaseStatusNode(data: data, maxComparationValue: maxComparationValue)
        
        return node
    }
    
    private func setupWeaknessGroupNodeUI() {
        guard pokemonData.weaknesses.count > 0 else { return }
        
        let node = ASDisplayNode()
        node.automaticallyManagesSubnodes = true

        let titleWeaknessNode = ASTextNode()
        titleWeaknessNode.attributedText = NSAttributedString(string: "Weakness", attributes: [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .bold),
        NSAttributedString.Key.foregroundColor: UIColor.blackPallete])

        var weaknessChips: [ASDisplayNode] = []
        
        for dataWeakness in pokemonData.weaknesses {
            let node = generatesWeaknessChips(type: dataWeakness)
            weaknessChips.append(node)
        }
        
        node.layoutSpecBlock = { _,_ in
            let chipsStack = ASStackLayoutSpec.horizontal()
            chipsStack.spacing = 8
            chipsStack.flexWrap = .wrap
            chipsStack.alignItems = .start
            chipsStack.justifyContent = .start

            for chips in weaknessChips {
                chipsStack.children?.append(ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0), child: chips))
            }
            
            let contentStack = ASStackLayoutSpec.vertical()
            contentStack.alignItems = .start
            contentStack.justifyContent = .start
            contentStack.flexWrap = .wrap
            contentStack.spacing = 8
            contentStack.children = [
                titleWeaknessNode,
                chipsStack
            ]
            
            contentStack.style.width = ASDimensionMake("100%")
            contentStack.style.flexGrow = 1
            contentStack.style.flexShrink = 1
            contentStack.style.flexBasis = ASDimensionMake(.fraction, 1)
            
            return contentStack
        }
        
        weaknessGroupNode = node
    }
    
    private func generatesWeaknessChips(type weaknessType: String) -> ASDisplayNode {
        let node = ASDisplayNode()
        let typesText = ASTextNode()
        let bgColor: UIColor
        
        switch weaknessType.lowercased() {
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
        
        node.automaticallyManagesSubnodes = true
        node.backgroundColor = bgColor.withAlphaComponent(0.7)
        node.style.height = ASDimensionMake(24)
        node.cornerRadius = 12
        node.style.flexGrow = 1
        node.style.flexShrink = 1
        
        let typesTextString: NSAttributedString = NSAttributedString(string: weaknessType, attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ])
        
        typesText.attributedText = typesTextString
        
        node.layoutSpecBlock = { _,_ -> ASLayoutSpec in
            let stack = ASStackLayoutSpec.vertical()
            stack.spacing = 0
            stack.alignItems = .center
            stack.justifyContent = .center
            stack.child = typesText
            
            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16), child: stack)
        }
        
        return node
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
