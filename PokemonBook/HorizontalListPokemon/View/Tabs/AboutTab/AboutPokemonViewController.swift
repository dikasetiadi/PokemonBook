//
//  AboutPokemonViewController.swift
//  PokemonBook
//
//  Created by Nakama on 09/01/20.
//  Copyright © 2020 dikasetiadi. All rights reserved.
//

import AsyncDisplayKit

internal class AboutPokemonViewController: ASDKViewController<ASScrollNode> {
    private let rootNode: ASScrollNode = {
        let node = ASScrollNode()
        node.automaticallyManagesContentSize = true
        node.automaticallyManagesSubnodes = true
        node.backgroundColor = .white
        
        return node
    }()
    
    private lazy var aboutTextNode: ASTextNode = {
        let node = ASTextNode()
        let textString = NSAttributedString(string: pokemonData.xdescription, attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold),
            NSAttributedString.Key.foregroundColor: UIColor.black
        ])
        node.attributedText = textString
        
        return node
    }()
    
    private lazy var AboutPhysicalInfoNode: ASDisplayNode = {
        let node = ASDisplayNode()
        node.automaticallyManagesSubnodes = true
        node.backgroundColor = .white
        node.cornerRadius = 12
        node.clipsToBounds = false
        
        node.shadowColor = #colorLiteral(red: 0.1921568627, green: 0.2078431373, blue: 0.231372549, alpha: 1).cgColor
        node.shadowOffset = CGSize(width: 0, height: 8)
        node.shadowOpacity = 0.12
        node.shadowRadius = 23
        
        node.style.width = ASDimensionMake("100%")
        
        //setup all height text info
        let heightTitleNode = ASTextNode()
        let heightTextNode = ASTextNode()
        
        heightTitleNode.attributedText = NSAttributedString(string: "Height", attributes: [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold),
        NSAttributedString.Key.foregroundColor: UIColor.blackPallete.withAlphaComponent(0.4)])
        
        heightTextNode.attributedText = NSAttributedString(string: pokemonData.height, attributes: [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold),
        NSAttributedString.Key.foregroundColor: UIColor.blackPallete])
        
        //setup all weight text info
        let weightTitleNode = ASTextNode()
        let weightTextNode = ASTextNode()
        
        weightTitleNode.attributedText = NSAttributedString(string: "Weight", attributes: [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold),
        NSAttributedString.Key.foregroundColor: UIColor.blackPallete.withAlphaComponent(0.4)])
        
        weightTextNode.attributedText = NSAttributedString(string: pokemonData.weight, attributes: [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold),
        NSAttributedString.Key.foregroundColor: UIColor.blackPallete])
        
        node.layoutSpecBlock = { _,_ in
            let stackLeft = ASStackLayoutSpec.vertical()
            stackLeft.spacing = 11
            stackLeft.children = [
                heightTitleNode,
                heightTextNode,
            ]
            stackLeft.style.flexGrow = 1
            stackLeft.style.flexShrink = 1
            stackLeft.style.flexBasis = ASDimensionMake(.fraction, 1)
            
            let stackRight = ASStackLayoutSpec.vertical()
            stackRight.spacing = 11
            stackRight.children = [
                weightTitleNode,
                weightTextNode
            ]
            stackRight.style.flexGrow = 1
            stackRight.style.flexShrink = 1
            stackRight.style.flexBasis = ASDimensionMake(.fraction, 1)
            
            let contentStack = ASStackLayoutSpec.horizontal()
            contentStack.alignItems = .start
            contentStack.justifyContent = .start
            contentStack.children = [
                stackLeft,
                stackRight
            ]
            
            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16, left: 22, bottom: 16, right: 22), child: contentStack)
        }
        
        return node
    }()
    
    private lazy var breedingInfoGroupNode: ASDisplayNode = {
        let node = ASDisplayNode()
        node.automaticallyManagesSubnodes = true

        //setup all breeding text info
        let breedingTitleNode = ASTextNode()
        let genderTextTitleNode = ASTextNode()
        let eggGroupTextTitleNode = ASTextNode()
        let eggCycleTextTitleNode = ASTextNode()

        let genderFemaleTextNode = ASTextNode()
        let genderFemaleIconNode = ASImageNode()
        let genderMaleTextNode = ASTextNode()
        let genderMaleIconNode = ASImageNode()
        
        let eggGroupTextNode = ASTextNode()
        let eggCycleTextNode = ASTextNode()
        
        //title
        breedingTitleNode.attributedText = NSAttributedString(string: "Breeding", attributes: [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .bold),
        NSAttributedString.Key.foregroundColor: UIColor.blackPallete])
        
        //gender
        genderTextTitleNode.attributedText = NSAttributedString(string: "Gender", attributes: [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold),
        NSAttributedString.Key.foregroundColor: UIColor.blackPallete.withAlphaComponent(0.6)])
        genderTextTitleNode.style.minWidth = ASDimensionMake(88)

        genderMaleTextNode.attributedText = NSAttributedString(string: pokemonData.male_percentage ?? "0%", attributes: [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold),
        NSAttributedString.Key.foregroundColor: UIColor.blackPallete])
        genderMaleIconNode.image = #imageLiteral(resourceName: "male")
        genderMaleTextNode.contentMode = .scaleAspectFit
        genderMaleIconNode.style.preferredSize = CGSize(width: 11, height: 11)

        genderFemaleTextNode.attributedText = NSAttributedString(string: pokemonData.female_percentage ?? "0%", attributes: [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold),
        NSAttributedString.Key.foregroundColor: UIColor.blackPallete])
        genderFemaleIconNode.image = #imageLiteral(resourceName: "female")
        genderFemaleIconNode.contentMode = .scaleAspectFit
        genderFemaleIconNode.style.preferredSize = CGSize(width: 9, height: 15)
        
        // egg group
        eggGroupTextTitleNode.attributedText = NSAttributedString(string: "Egg Groups", attributes: [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold),
        NSAttributedString.Key.foregroundColor: UIColor.blackPallete.withAlphaComponent(0.6)])
        eggGroupTextTitleNode.style.minWidth = ASDimensionMake(88)
        
        eggGroupTextNode.attributedText = NSAttributedString(string: pokemonData.egg_groups, attributes: [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold),
        NSAttributedString.Key.foregroundColor: UIColor.blackPallete])
        
        // egg Cycle
        eggCycleTextTitleNode.attributedText = NSAttributedString(string: "Egg Cycle", attributes: [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold),
        NSAttributedString.Key.foregroundColor: UIColor.blackPallete.withAlphaComponent(0.6)])
        eggCycleTextTitleNode.style.minWidth = ASDimensionMake(88)
        
        eggCycleTextNode.attributedText = NSAttributedString(string: pokemonData.typeofpokemon[0], attributes: [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold),
        NSAttributedString.Key.foregroundColor: UIColor.blackPallete])
        
        node.layoutSpecBlock = { _,_ in
            //gender layout
            let genderMaleStack = ASStackLayoutSpec.horizontal()
            genderMaleStack.spacing = 8
            genderMaleStack.alignItems = .center
            genderMaleStack.justifyContent = .start
            genderMaleStack.children = [
                genderMaleIconNode,
                genderMaleTextNode
            ]
            
            let genderFemaleStack = ASStackLayoutSpec.horizontal()
            genderFemaleStack.spacing = 4
            genderFemaleStack.alignItems = .center
            genderFemaleStack.justifyContent = .start
            genderFemaleStack.children = [
                genderFemaleIconNode,
                genderFemaleTextNode
            ]
            
            let genderStack = ASStackLayoutSpec.horizontal()
            genderStack.alignItems = .center
            genderStack.justifyContent = .start
            genderStack.spacing = 13
            genderStack.children = [
                genderTextTitleNode,
                genderMaleStack,
                genderFemaleStack
            ]
            
            //egg group
            let eggGroupStack = ASStackLayoutSpec.horizontal()
            eggGroupStack.alignItems = .center
            eggGroupStack.justifyContent = .start
            eggGroupStack.spacing = 13
            eggGroupStack.children = [
                eggGroupTextTitleNode,
                eggGroupTextNode,
            ]
            
            //egg cycle
            let eggCycleStack = ASStackLayoutSpec.horizontal()
            eggCycleStack.alignItems = .center
            eggCycleStack.justifyContent = .start
            eggCycleStack.spacing = 13
            eggCycleStack.children = [
                eggCycleTextTitleNode,
                eggCycleTextNode,
            ]
            
            let contentStack = ASStackLayoutSpec.vertical()
            contentStack.spacing = 16
            contentStack.children = [
                ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0), child: breedingTitleNode),
                genderStack,
                eggGroupStack,
                eggCycleStack
            ]
            
            return contentStack
        }
        
        return node
    }()
    
    private lazy var locationInfoNode: ASDisplayNode = {
        let node = ASDisplayNode()
        node.automaticallyManagesSubnodes = true
        
        let LocationTextTitleNode = ASTextNode()
        let LocationIconNode = ASImageNode()
        
        //title
        LocationTextTitleNode.attributedText = NSAttributedString(string: "Location", attributes: [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .bold),
        NSAttributedString.Key.foregroundColor: UIColor.blackPallete])
        
        LocationIconNode.image = #imageLiteral(resourceName: "map")
        LocationIconNode.contentMode = .scaleAspectFit
        LocationIconNode.style.preferredSize = CGSize(width: UIScreen.main.bounds.width - 32, height: 142)
        LocationIconNode.cornerRadius = 12
        
        node.layoutSpecBlock = { _,_ in
            let contentStack = ASStackLayoutSpec.vertical()
                contentStack.spacing = 16
                contentStack.children = [
                    LocationTextTitleNode,
                    LocationIconNode
                ]
                
            return contentStack
        }
        
        return node
    }()
    
    private lazy var trainingInfoNode: ASDisplayNode = {
        let node = ASDisplayNode()
        node.automaticallyManagesSubnodes = true
        
        let trainingTitleNode = ASTextNode()
        let baseEXPTextTitleNode = ASTextNode()
        let baseEXPTextNode = ASTextNode()
        
        //title
        trainingTitleNode.attributedText = NSAttributedString(string: "Training", attributes: [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .bold),
        NSAttributedString.Key.foregroundColor: UIColor.blackPallete])
        
        //baseExp
        baseEXPTextTitleNode.attributedText = NSAttributedString(string: "Base EXP", attributes: [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold),
        NSAttributedString.Key.foregroundColor: UIColor.blackPallete.withAlphaComponent(0.6)])
        baseEXPTextTitleNode.style.minWidth = ASDimensionMake(88)
        
        baseEXPTextNode.attributedText = NSAttributedString(string: pokemonData.base_exp, attributes: [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .semibold),
        NSAttributedString.Key.foregroundColor: UIColor.blackPallete])
        
        node.layoutSpecBlock = { _,_ in
            let trainingStack = ASStackLayoutSpec.horizontal()
            trainingStack.alignItems = .center
            trainingStack.justifyContent = .start
            trainingStack.spacing = 13
            trainingStack.children = [
                baseEXPTextTitleNode,
                baseEXPTextNode
            ]
            
            let contentStack = ASStackLayoutSpec.vertical()
                contentStack.spacing = 16
                contentStack.children = [
                    ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0), child: trainingTitleNode),
                    trainingStack
                ]
                
            return contentStack
        }
        
        return node
    }()
    
    private var pokemonData: ListPokemonDataDummy
    
    init(data: ListPokemonDataDummy) {
        pokemonData = data
        super.init(node: rootNode)
        
        title = "About"
        
        setupUI()
    }
    
    private func setupUI() {
        rootNode.layoutSpecBlock = { [weak self] _,_ -> ASLayoutSpec in
            guard let self = self else { return ASLayoutSpec() }
            
            let stack = ASStackLayoutSpec.vertical()
            stack.alignItems = .start
            stack.justifyContent = .start
            stack.spacing = 24
            stack.children = [
                self.aboutTextNode,
                self.AboutPhysicalInfoNode,
                self.breedingInfoGroupNode,
                self.locationInfoNode,
                self.trainingInfoNode
            ]
            stack.style.width = ASDimensionMake("100%")
            
            let inset = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16), child: stack)
            
            return ASWrapperLayoutSpec(layoutElement: inset)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
