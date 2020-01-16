//
//  DetailPokemonViewController.swift
//  PokemonBook
//
//  Created by Nakama on 06/01/20.
//  Copyright © 2020 dikasetiadi. All rights reserved.
//

import AsyncDisplayKit
import Parchment

internal class DetailPokemonViewController: ASViewController<ASDisplayNode> {
    
    private enum State {
        case partial
        case full
        
        var thresholdMultiplier: CGFloat {
            switch self {
            case .full: return 0.2
            case .partial: return 0.5
            }
        }
    }
    
    private lazy var safeAreaInset: UIEdgeInsets = {
        if #available(iOS 11.0, *), let safeArea = UIApplication.shared.keyWindow?.safeAreaInsets {
            return safeArea
        }
        
        return .zero
    }()
    
    private var statusBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.height
    }
    
    private var rootNode: ASDisplayNode = {
        let node = ASDisplayNode()
        node.automaticallyManagesSubnodes = true
        
        return node
    }()
    
    private lazy var backgroundNode: ASDisplayNode = {
        let node = ASDisplayNode()
        node.backgroundColor = bgColor
        node.style.width = ASDimensionMake("100%")
        node.style.height = ASDimensionMake("100%")
        
        return node
    }()
    
    public lazy var pokemonImageNode: ASNetworkImageNode = {
        let node = ASNetworkImageNode()
        node.url = URL(string: urlImage)
        node.style.preferredSize = CGSize(width: 175, height: 175)
        node.contentMode = .scaleAspectFit
        node.displaysAsynchronously = false
        
        return node
    }()
    
    public lazy var pokemonCategoryNode: ASTextNode = {
        let node = ASTextNode()
        node.maximumNumberOfLines = 1
        node.truncationMode = .byTruncatingTail
        node.alpha = 0
        
        return node
    }()
    
    public lazy var pokemonNameNode: ASTextNode = {
        let node = ASTextNode()
        let nameTextString: NSAttributedString = NSAttributedString(string: "\(pokemonData?.name ?? "")", attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 32, weight: .bold),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ])
        node.attributedText = nameTextString
        node.maximumNumberOfLines = 1
        node.truncationMode = .byTruncatingTail
        
        pokemonNameTextView.attributedText = nameTextString
        
        return node
    }()
    
    public lazy var pokemonIDNode: ASTextNode = {
        let node = ASTextNode()
        node.maximumNumberOfLines = 1
        node.truncationMode = .byTruncatingTail
        node.alpha = 0
        
        return node
    }()
    
    private lazy var pokemonLogoNode: ASImageNode = {
        let node = ASImageNode()
        node.style.preferredSize = CGSize(width: 200, height: 200)
        node.imageModificationBlock = ASImageNodeTintColorModificationBlock(UIColor.white.withAlphaComponent(0.2))
        node.image = #imageLiteral(resourceName: "pokeball")
        node.alpha = 0
        return node
    }()
    
    public lazy var bottomInfoNode: ASDisplayNode = {
        let node = ASDisplayNode()
        node.automaticallyManagesSubnodes = true
        node.style.flexGrow = 1
        node.style.flexShrink = 1
        node.style.flexBasis = ASDimensionMake(.fraction, 1)
        node.backgroundColor = .white
        node.style.width = ASDimensionMake("100%")
        
        let gap = bottomSheetLastState == .partial ? pokemonImageNode.frame.maxY : headerNode.frame.height
        let height = self.node.frame.height - gap
        node.style.height = ASDimensionMake(height)
        
        node.layoutSpecBlock = { [weak self] _,_ in
            guard let self = self else { return ASLayoutSpec() }
            
            return ASWrapperLayoutSpec(layoutElements: [self.tabsNode])
        }
        
        return node
    }()
    
    public lazy var pokemonNameHeaderNode: ASTextNode = {
        let node = ASTextNode()
        let nameTextString: NSAttributedString = NSAttributedString(string: "\(pokemonData?.name ?? "")", attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22, weight: .bold),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ])
        node.attributedText = nameTextString
        node.maximumNumberOfLines = 1
        node.truncationMode = .byTruncatingTail
        node.alpha = 0
        
        return node
    }()
    
    private lazy var headerNode: ASDisplayNode = {
        let node = ASDisplayNode()
        node.style.width = ASDimensionMake("100%")
        node.automaticallyManagesSubnodes = true
        node.alpha = 0
        node.layoutSpecBlock = { [weak self] _,_ -> ASLayoutSpec in
            guard let self = self else { return ASLayoutSpec() }
            
            let stack = ASStackLayoutSpec.horizontal()
            stack.spacing = 12
            stack.alignItems = .center
            stack.justifyContent = .start
            stack.children = [
                self.backIconNode,
                self.pokemonNameHeaderNode
            ]
            
            let allStack = ASStackLayoutSpec.horizontal()
            allStack.alignItems = .center
            allStack.justifyContent = .spaceBetween
            allStack.children = [
                stack,
                self.loveIconNode
            ]
            
            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16, left: 12, bottom: 8, right: 16), child: allStack)
        }
        
        return node
    }()
    
    private lazy var backIconNode: ASImageNode = {
        let iconNode = ASImageNode()
        iconNode.image = #imageLiteral(resourceName: "back_navigation")
        iconNode.style.preferredSize = CGSize(width: 24, height: 24)
        iconNode.contentMode = .scaleAspectFit
        iconNode.addTarget(self, action: #selector(popThisPage), forControlEvents: .touchUpInside)
        
        return iconNode
    }()
    
    private lazy var loveIconNode: ASImageNode = {
        let iconNode = ASImageNode()
        iconNode.image = #imageLiteral(resourceName: "wishlist")
        iconNode.style.preferredSize = CGSize(width: 24, height: 24)
        iconNode.contentMode = .scaleAspectFit
        iconNode.addTarget(self, action: #selector(popThisPage), forControlEvents: .touchUpInside)
        iconNode.imageModificationBlock = ASImageNodeTintColorModificationBlock(.white)
        
        return iconNode
    }()
    
    public var urlImage: String = "" {
        didSet {
            pokemonImageNode.url = URL(string: urlImage)
            rootNode.transitionLayout(withAnimation: false, shouldMeasureAsync: false, measurementCompletion: nil)
        }
    }
    
    public var bgColor: UIColor = .white {
        didSet {
            rootNode.backgroundColor = bgColor
            rootNode.transitionLayout(withAnimation: false, shouldMeasureAsync: false, measurementCompletion: nil)
        }
    }
    
    internal var pokemonData: ListPokemonDataDummy? = nil {
        didSet {
            setupTypesNodeUI()
            rootNode.transitionLayout(withAnimation: false, shouldMeasureAsync: false, measurementCompletion: nil)
        }
    }
    
    private lazy var tabView: FixedPagingViewController = {
        let tabs = FixedPagingViewController(viewControllers: [aboutViewController, evolutionViewController, baseStatusViewController])
        tabs.menuItemSize = .fixed(width: UIScreen.main.bounds.width / 3, height: 50)
        tabs.menuHorizontalAlignment = .center
        tabs.borderOptions = .visible(height: 2, zIndex: Int.max - 1, insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        tabs.borderColor = UIColor.greyPallete.withAlphaComponent(0.12)
        tabs.indicatorColor = .lightPurplePallete
        tabs.indicatorOptions = .visible(height: 2, zIndex: Int.max, spacing: UIEdgeInsets.zero, insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        tabs.textColor = UIColor.greyPallete.withAlphaComponent(0.3)
        tabs.selectedTextColor = UIColor.blackPallete
        
        return tabs
    }()
    
    private lazy var tabsNode: ASDisplayNode = {
        let node = ASDisplayNode { [weak self] () -> UIView in
            guard let self = self else { return UIView() }
            
            return self.tabView.view
        }
        
        node.style.flexGrow = 1
        node.style.flexShrink = 1
        node.style.flexBasis = ASDimensionMake(.fraction, 1)
        node.backgroundColor = .white
        
        return node
    }()
    
    internal var typesArrNode: [ASDisplayNode] = []
    internal var typesArrView: [UIView] = []
    internal var typesTextViewArr: [UILabel] = []
    internal let pokemonNameTextView: UILabel = UILabel()
    
    private var gapY: CGFloat = 0
    private var selectedIndex: Int = 0
    private var bottomSheetLastState: State = .partial {
        didSet {
            let isCanScroll = bottomSheetLastState == .full
            for vc in tabView.viewControllers {
                if let viewController = vc.view as? UIScrollView {
                    viewController.isScrollEnabled = isCanScroll
                }
            }
        }
    }
    
    private lazy var aboutViewController: AboutPokemonViewController = {
        let vc = AboutPokemonViewController(data: pokemonData!)
        vc.node.view.isScrollEnabled = false
        vc.node.view.delegate = self
        
        return vc
    }()
    
    private lazy var evolutionViewController: EvolutionPokemonViewController = {
        let vc = EvolutionPokemonViewController(data: pokemonData!)
        vc.node.view.isScrollEnabled = false
        vc.node.view.delegate = self
        
        return vc
    }()
    
    private lazy var baseStatusViewController: BaseStatusPokemonViewController = {
        let vc = BaseStatusPokemonViewController(data: pokemonData!)
        vc.node.view.isScrollEnabled = false
        vc.node.view.delegate = self
        
        return vc
    }()
    
    private lazy var heightForPartialBottomSheet: CGFloat = {
        let viewHeight = node.frame.height - pokemonImageNode.frame.maxY
        
        return viewHeight
    }()
    
    private lazy var heightForFullBottomSheet: CGFloat = {
        let topInset: CGFloat = self.safeAreaInset.top.isZero ? self.statusBarHeight : self.safeAreaInset.top
        
        let viewHeight = node.frame.height - (topInset + headerNode.frame.height)
        return viewHeight
    }()
    
    init() {
        super.init(node: rootNode)
        
        setupUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(tabView)
        tabView.didMove(toParent: self)
        tabView.delegate = self
        
        let bottomSwipeGesture = PanDirectionGestureRecognizer(direction: .vertical, target: self, action: #selector(handleBottomInfoSwipe(_:)))
        bottomSwipeGesture.cancelsTouchesInView = false
        bottomSwipeGesture.delegate = self
        bottomSwipeGesture.maximumNumberOfTouches = 1
        bottomInfoNode.view.addGestureRecognizer(bottomSwipeGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupBottomNodeUI()
        tabView.view.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tabView.select(index: selectedIndex, animated: true)
        
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = CGFloat.pi * 2
        rotation.duration = 3.5
        rotation.isCumulative = true
        rotation.repeatCount = .greatestFiniteMagnitude
        rotation.fillMode = .forwards
        rotation.isRemovedOnCompletion = false
        
        let animationCategory = CATransition()
        animationCategory.type = .push
        animationCategory.subtype = .fromRight
        animationCategory.duration = 0.5
        animationCategory.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animationCategory.isRemovedOnCompletion = false
        
        let categoryTextString: NSAttributedString = NSAttributedString(string: "\(pokemonData?.category ?? "") Pokemon", attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12, weight: .bold),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ])
        
        let animationIdNode = CATransition()
        animationIdNode.type = .push
        animationIdNode.subtype = .fromRight
        animationIdNode.duration = 0.65
        animationIdNode.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animationIdNode.isRemovedOnCompletion = false
        
        let idTextString: NSAttributedString = NSAttributedString(string: "\(pokemonData?.id ?? "")", attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .bold),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ])
        
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.headerNode.alpha = 1
            self?.pokemonLogoNode.alpha = 1
            self?.pokemonLogoNode.layer.add(rotation, forKey: "rotationAnimation")
            self?.pokemonCategoryNode.attributedText = categoryTextString
            self?.pokemonCategoryNode.alpha = 1
            self?.pokemonCategoryNode.layer.add(animationCategory, forKey: "slideCategory")
            self?.pokemonIDNode.attributedText = idTextString
            self?.pokemonIDNode.alpha = 1
            self?.pokemonIDNode.layer.add(animationIdNode, forKey: "slideIdNode")
        })
    }
    
    private func setupUI() {
        rootNode.layoutSpecBlock = { [weak self] _,_ in
            guard let self = self else { return ASLayoutSpec() }
            
            let topInset: CGFloat = self.safeAreaInset.top.isZero ? self.statusBarHeight : self.safeAreaInset.top
            
            let imageStack = ASAbsoluteLayoutSpec(children: [
                ASInsetLayoutSpec(insets: UIEdgeInsets(top: topInset + 40 + 32, left: .infinity, bottom: 0, right: .infinity), child: self.pokemonLogoNode)
            ])
            
            let infoNameAndIDStack = ASStackLayoutSpec.horizontal()
            infoNameAndIDStack.alignItems = .center
            infoNameAndIDStack.justifyContent = .spaceBetween
            infoNameAndIDStack.spacing = 8
            infoNameAndIDStack.children = [
                self.pokemonNameNode,
                self.pokemonIDNode
            ]
            infoNameAndIDStack.style.width = ASDimensionMake("100%")
            
            let insetStackNameID = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8, left: 16, bottom: 0, right: 16), child: infoNameAndIDStack)
            
            let stackTypes = ASStackLayoutSpec.horizontal()
            stackTypes.spacing = 8
            stackTypes.children = self.typesArrNode
            
            let horizontalStackTypeCategory = ASStackLayoutSpec.horizontal()
            horizontalStackTypeCategory.justifyContent = .spaceBetween
            horizontalStackTypeCategory.alignItems = .center
            horizontalStackTypeCategory.children = [
                stackTypes,
                self.pokemonCategoryNode
            ]
            horizontalStackTypeCategory.style.width = ASDimensionMake("100%")
            
            let insetStackTypes = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8, left: 16, bottom: 0, right: 16), child: horizontalStackTypeCategory)
            
            let stack = ASStackLayoutSpec.vertical()
            stack.alignItems = .start
            stack.justifyContent = .start
            stack.spacing = 0
            stack.children = [
                self.headerNode,
                insetStackNameID,
                insetStackTypes,
                ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16, left: .infinity, bottom: 0, right: .infinity), child: self.pokemonImageNode)
            ]
            stack.style.width = ASDimensionMake("100%")
            stack.style.height = ASDimensionMake("100%")
            stack.style.flexGrow = 1
            stack.style.flexShrink = 1
            stack.style.flexBasis = ASDimensionMake(.fraction, 1)
            
            let inset = ASInsetLayoutSpec(insets: UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0), child: stack)
            
            if self.gapY.isZero {
                self.gapY = self.bottomSheetLastState == .partial ? self.pokemonImageNode.frame.maxY : self.headerNode.frame.maxY
            }
            
            let insetBottomInfo = ASInsetLayoutSpec(insets: UIEdgeInsets(top: self.gapY, left: 0, bottom: 0, right: 0), child: self.bottomInfoNode)
            
            return ASAbsoluteLayoutSpec(sizing: .default, children: [self.backgroundNode, imageStack, inset, insetBottomInfo])
        }
    }
    
    private func setupTypesNodeUI() {
        if let countTypes = pokemonData?.typeofpokemon {
            
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
                node.backgroundColor = bgColor
                node.style.height = ASDimensionMake(24)
                node.cornerRadius = 12
                node.style.flexGrow = 1
                node.style.flexShrink = 1
                node.shadowColor = #colorLiteral(red: 0.1921568627, green: 0.2078431373, blue: 0.231372549, alpha: 1).cgColor
                node.shadowOffset = CGSize(width: 0, height: 1)
                node.shadowOpacity = 0.2
                node.shadowRadius = 6
                
                let typesTextString = NSAttributedString(string: data, attributes: [
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
                
                typesArrNode.append(node)
                typesArrView.append(node.view)
                
                let textLabel = UILabel()
                textLabel.attributedText = typesTextString
                textLabel.frame = typesText.frame
                
                typesTextViewArr.append(textLabel)
            }
        }
    }
    
    private func setupBottomNodeUI() {
        if #available(iOS 11.0, *) {
            bottomInfoNode.layer.cornerRadius = 16
            bottomInfoNode.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            // Fallback on earlier versions
            let path = UIBezierPath(roundedRect: bottomInfoNode.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 16, height: 16))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            bottomInfoNode.layer.mask = mask
        }
        
        bottomInfoNode.layer.masksToBounds = true
    }
    
    private func switchAnimationWithProgress(withProgress progress: CGFloat) {
        self.pokemonNameHeaderNode.alpha = 1 - progress
        self.pokemonNameNode.alpha = progress
        self.pokemonIDNode.alpha = progress
        self.pokemonLogoNode.alpha = progress
        self.pokemonCategoryNode.alpha = progress
        for chips in self.typesArrNode {
            chips.alpha = progress
        }
        self.pokemonImageNode.alpha = progress
    }
    
    private func switchAnimation(forState: State) {
        
        switch forState {
        case .partial:
            UIView.animateKeyframes(withDuration: 0.24, delay: 0, options: .beginFromCurrentState, animations: { [weak self] in
                guard let self = self else { return }
                self.pokemonNameHeaderNode.alpha = 0
                self.pokemonNameNode.alpha = 1
                self.pokemonIDNode.alpha = 1
                self.pokemonLogoNode.alpha = 1
                self.pokemonCategoryNode.alpha = 1
                for chips in self.typesArrNode {
                    chips.alpha = 1
                }
                self.pokemonImageNode.alpha = 1
                }, completion: nil)
            break
        case .full:
            UIView.animateKeyframes(withDuration: 0.24, delay: 0, options: .beginFromCurrentState, animations: { [weak self] in
                guard let self = self else { return }
                self.pokemonNameHeaderNode.alpha = 1
                self.pokemonNameNode.alpha = 0
                self.pokemonIDNode.alpha = 0
                self.pokemonLogoNode.alpha = 0
                self.pokemonCategoryNode.alpha = 0
                for chips in self.typesArrNode {
                    chips.alpha = 0
                }
                self.pokemonImageNode.alpha = 0
                }, completion: nil)
            break
        }
        
    }
    
    @objc private func popThisPage() {
        
        if bottomSheetLastState == .full {
            if let VCscrollView = tabView.viewControllers[selectedIndex].view as? UIScrollView {
                VCscrollView.setContentOffset(.zero, animated: true)
            }
            switchAnimation(forState: .partial)
            setBottomSheetView(for: .partial)
        }
        
        UIView.animate(withDuration: 0.5, delay: bottomSheetLastState == .full ? 0.24 : 0, options: .preferredFramesPerSecond60, animations: { [weak self] in
            self?.headerNode.alpha = 0
            self?.pokemonLogoNode.alpha = 0
            self?.pokemonIDNode.alpha = 0
            self?.pokemonCategoryNode.alpha = 0
            }, completion: {[weak self] (finished) in
                self?.pokemonIDNode.layer.removeAllAnimations()
                self?.pokemonCategoryNode.layer.removeAllAnimations()
                self?.pokemonLogoNode.layer.removeAllAnimations()
                self?.navigationController?.popViewController(animated: true)
        })
    }
    
    @objc private func handleBottomInfoSwipe(_ gesture: UIPanGestureRecognizer) {
        let translationY = gesture.translation(in: view).y
        gesture.setTranslation(.zero, in: view)
        
        if let VCscrollView = tabView.viewControllers[selectedIndex].view as? UIScrollView, VCscrollView.contentOffset.y > 0 { return }
        
        if gesture.state == .began || gesture.state == .changed {
            let top = gapY
            let visibleHeight: CGFloat = node.frame.height - top
            let shouldTranslate = shouldTranslateView(for: translationY, withVisibleHeight: visibleHeight, partialHeight: heightForPartialBottomSheet, fullHeight: heightForFullBottomSheet)
            guard shouldTranslate else { return }
            
            gapY += translationY
            rootNode.setNeedsLayout()
            let bottomValue = bottomSheetLastState == .partial ? pokemonImageNode.frame.maxY : heightForPartialBottomSheet
            
            let calculationProgress = (gapY / bottomValue)
            switchAnimationWithProgress(withProgress: calculationProgress)
            
        } else if gesture.state == .ended {
            let currentY = gapY
            let isBelowHalf = currentY >= (node.frame.height * bottomSheetLastState.thresholdMultiplier)
            let state: State = isBelowHalf ? .partial : .full
            
            if state == .partial, let VCscrollView = tabView.viewControllers[selectedIndex].view as? UIScrollView {
                // just to make sure this tab cannot be swiped down
                VCscrollView.isScrollEnabled = false
                VCscrollView.setContentOffset(.zero, animated: false)
            }
            
            switchAnimation(forState: state)
            setBottomSheetView(for: state)
            bottomSheetLastState = state
        }
    }
    
    private func setBottomSheetView(for state: State) {
        if let VCscrollView = tabView.viewControllers[selectedIndex].view as? UIScrollView, bottomSheetLastState == .partial {
            VCscrollView.setContentOffset(.zero, animated: false)
            VCscrollView.isScrollEnabled = false
        }
        
        var viewHeight: CGFloat
        switch state {
        case .partial: viewHeight = heightForPartialBottomSheet
        case .full: viewHeight = heightForFullBottomSheet
        }
        
        let top = node.frame.height - viewHeight
        gapY = top
        
        UIView.animate(withDuration: 0.24, animations: { [weak self] in
            guard let self = self else { return }
            self.bottomInfoNode.frame.origin.y = self.gapY
            
            if state == .full {
                self.rootNode.setNeedsLayout()
            }
        }) { [weak self] (finished) in
            if finished, state == .partial {
                self?.rootNode.setNeedsLayout()
            }
        }
    }
    
    /// Method to check the threshold value with the new translation
    /// - Parameters:
    ///   - translationY: y translation of the gesture
    ///   - visibleHeight: current height of the view
    ///   - partialHeight: partial state height of view
    ///   - fullHeight: full state height of view
    private func shouldTranslateView(for translationY: CGFloat, withVisibleHeight visibleHeight: CGFloat, partialHeight: CGFloat, fullHeight: CGFloat) -> Bool {
        if translationY > 0, (visibleHeight - translationY) > (partialHeight) {
            return true
        } else if translationY < 0, (visibleHeight - translationY) < fullHeight {
            return true
        }
        return false
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DetailPokemonViewController: AnimateAbleProtocol {
    var nameTextView: UILabel {
        let nameTextLabel = UILabel()
        nameTextLabel.attributedText = pokemonNameNode.attributedText
        nameTextLabel.frame = pokemonNameNode.frame
        
        return nameTextLabel
    }
    
    var typesTextView: [UILabel] {
        get {
            return typesTextViewArr
        }
        set {
            typesTextViewArr = newValue
        }
    }
    
    var typesView: [UIView] {
        get {
            return typesArrView
        }
        set {
            typesArrView = newValue
        }
    }
    
    var cellImageView: UIImageView {
        let imgView = UIImageView()
        imgView.frame = pokemonImageNode.frame
        imgView.image = pokemonImageNode.image
        
        return imgView
    }
    
    var backgroundColor: UIView {
        rootNode.view
    }
    
    var cellBackground: UIView {
        bottomInfoNode.frame.origin.y = pokemonImageNode.frame.origin.y + pokemonImageNode.frame.size.height
        return bottomInfoNode.view
    }
}

extension DetailPokemonViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if let VCscrollView = tabView.viewControllers[selectedIndex].view as? UIScrollView, VCscrollView.contentOffset.y > 0, bottomSheetLastState == .full {
            return false
        }
        
        return true
    }
}

extension DetailPokemonViewController: PagingViewControllerDelegate {
    func pagingViewController<T>(_ pagingViewController: PagingViewController<T>, didScrollToItem pagingItem: T, startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) where T : PagingItem, T : Comparable, T : Hashable {
        if transitionSuccessful {
            guard let indexItem = pagingViewController.state.currentPagingItem as? PagingIndexItem else {
                return
            }
            
            selectedIndex = indexItem.index
            
            if let fromVC = startingViewController, let fromVCView = fromVC.view as? UIScrollView, let toVC = destinationViewController.view as? UIScrollView {
                fromVCView.setContentOffset(.zero, animated: false)
                toVC.setContentOffset(.zero, animated: false)
            }
        }
    }
}

extension DetailPokemonViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.isScrollEnabled = scrollView.contentOffset.y >= 0 && bottomSheetLastState == .full
    }
}
