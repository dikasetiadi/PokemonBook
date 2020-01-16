//
//  PokemonHorizontalCell.swift
//  PokemonBook
//
//  Created by Nakama on 02/01/20.
//  Copyright © 2020 dikasetiadi. All rights reserved.
//

import Foundation
import AsyncDisplayKit

internal class PokemonHorizontalCell: ASCellNode {
    private lazy var pokemonLogoNode: ASImageNode = {
        let node = ASImageNode()
        node.style.preferredSize = CGSize(width: 152, height: 152)
        node.imageModificationBlock = ASImageNodeTintColorModificationBlock(UIColor.gray.withAlphaComponent(0.4))
        node.image = #imageLiteral(resourceName: "pokeball")
        node.alpha = 0
        
        return node
    }()
    
    public lazy var pokemonImageNode: ASNetworkImageNode = {
        let node = ASNetworkImageNode()
        node.url = URL(string: pokemonData.imageurl)
        node.style.preferredSize = CGSize(width: 150, height: 150)
        node.contentMode = .scaleAspectFill
        node.displaysAsynchronously = false
        
        return node
    }()
    
    public lazy var cardNode: ASDisplayNode = {
        let node = ASDisplayNode()
        node.backgroundColor = .white
        node.style.width = ASDimensionMake("100%")
        node.style.height = ASDimensionMake("100%")
        node.cornerRadius = 8
        
        return node
    }()
    
    internal lazy var pokemonNameNode: ASTextNode = {
        let node = ASTextNode()
        let dataName = pokemonData.name
        let nameTextString = NSAttributedString(string: dataName, attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 32, weight: .semibold),
            NSAttributedString.Key.foregroundColor: UIColor.black.withAlphaComponent(0.7)
        ])
        node.attributedText = nameTextString
        
        return node
    }()
    
    private var pokemonData: ListPokemonDataDummy
    internal var frameCell: CGRect = .zero
    internal var typesNodeArr: [ASDisplayNode] = []
    internal var typesViewArr: [UIView] = []
    internal var typesTextViewArr: [UILabel] = []
    
    init(data: ListPokemonDataDummy) {
        pokemonData = data
        super.init()
        
        automaticallyManagesSubnodes = true
        isUserInteractionEnabled = true
        
        backgroundColor = .white
        cornerRadius = 8
        clipsToBounds = true
        
        shadowColor = #colorLiteral(red: 0.1921568627, green: 0.2078431373, blue: 0.231372549, alpha: 1).cgColor
        shadowOffset = CGSize(width: 0, height: 1)
        shadowOpacity = 0.12
        shadowRadius = 6
        
        setupUI()
    }
    
    internal func showLogo() {
        UIView.animate(withDuration: 0.24) { [weak self] in
            self?.pokemonLogoNode.alpha = 1
        }
    }
    
    internal func hideLogo() {
        UIView.animate(withDuration: 0.24) { [weak self] in
            self?.pokemonLogoNode.alpha = 0
        }
    }
    
    private func setupUI() {
        let countTypes = pokemonData.typeofpokemon
        
        for (_, data) in countTypes.enumerated() {
            let node = ASDisplayNode()
            let typesText = ASTextNode()
            let bgColor: UIColor
            
            switch data.lowercased() {
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
            
            let typesTextString: NSAttributedString = NSAttributedString(string: data, attributes: [
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
            
            typesNodeArr.append(node)
            typesViewArr.append(node.view)
            
            let textLabel = UILabel()
            textLabel.attributedText = typesTextString
            textLabel.frame = typesText.frame
            
            typesTextViewArr.append(textLabel)
        }
    }
        
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let leftContentStack = ASStackLayoutSpec.vertical()
        leftContentStack.spacing = 8
        leftContentStack.alignItems = .start
        leftContentStack.children = typesNodeArr
        
        let insetName = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0), child: pokemonNameNode)
        leftContentStack.children?.insert(insetName, at: 0)
        
        let stackContent = ASStackLayoutSpec.horizontal()
        stackContent.children = [
            leftContentStack
        ]
        
        let insetContent = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16), child: stackContent)
        
        let insetImagePokemon = ASInsetLayoutSpec(insets: UIEdgeInsets(top: .infinity, left: .infinity, bottom: 8, right: 8), child: pokemonImageNode)
        
        let insetLogo = ASInsetLayoutSpec(insets: UIEdgeInsets(top: .infinity, left: .infinity, bottom: -24, right: -16), child: pokemonLogoNode)
        
        let absWrapper = ASAbsoluteLayoutSpec(sizing: .default, children: [self.cardNode, insetLogo, insetImagePokemon, insetContent])
        
        return ASWrapperLayoutSpec(layoutElement: absWrapper)
    }
}
