//
//  ViewController2.swift
//  PlayingCard
//
//  Created by Soul on 17/5/2020.
//  Copyright © 2020 Soul. All rights reserved.
//

import UIKit

class ViewController2: UIViewController {
    private var deck = PlayingCardDeck()
    
    @IBOutlet private var cardViews: [PlayingCardView]!
    
    lazy var animator = UIDynamicAnimator(referenceView: view)
    
    lazy var cardBehavior = CardBehavior(in: animator)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var cards = [PlayingCard]()
        for _ in 1...((cardViews.count+1)/2) {
            let card = deck.draw()!
            cards += [card, card]
        }
        
        for cardView in cardViews {
            cardView.isFaceUp = false
            let card = cards.remove(at: cards.count.arc4random)
            cardView.rank = card.rank.order
            cardView.suit = card.suit.rawValue
            cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(filpCard(_:))))
            cardBehavior.addItem(cardView)
        }
    }
    
    //过滤正面朝上  隐藏已经匹配的卡片
    private var faceUpCardViews: [PlayingCardView] {
        return cardViews.filter { $0.isFaceUp && !$0.isHidden && 
            $0.transform != CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0) && 
            $0.alpha == 1
        }
    }
    
    private var faceUpCardViewsMatch : Bool {
        return faceUpCardViews.count == 2 && 
            faceUpCardViews[0].rank == faceUpCardViews[1].rank && 
            faceUpCardViews[0].suit == faceUpCardViews[1].suit
    }
    
    var lastChosenCardView: PlayingCardView?
    
    @objc func filpCard(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            if let chosenCardView = recognizer.view as? PlayingCardView, faceUpCardViews.count < 2 {
                lastChosenCardView = chosenCardView
                cardBehavior.removeItem(chosenCardView)
                
                UIView.transition(with: chosenCardView, duration: 0.5, options: [.transitionFlipFromLeft], animations: { 
                    chosenCardView.isFaceUp = !chosenCardView.isFaceUp
                }) { (finished) in
                    let cardsToAnimate = self.faceUpCardViews
                    
                    if self.faceUpCardViewsMatch {
                        
                        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.6, delay: 0, options: [], animations: { 
                            cardsToAnimate.forEach {
                                $0.transform = CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0)
                            }
                        }) { (position) in
                            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.75, delay: 0, options: [], animations: { 
                                cardsToAnimate.forEach {
                                    $0.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
                                    $0.alpha = 0
                                }
                            }) { (position) in
                                cardsToAnimate.forEach {
                                    $0.isHidden = true
                                    $0.alpha = 1
                                    $0.transform = .identity
                                }
                            }
                        }
                        
                    } else if cardsToAnimate.count == 2 {
                        if chosenCardView == self.lastChosenCardView {
                            cardsToAnimate.forEach { (cardView) in
                                UIView.transition(with: cardView, duration: 0.5, options: [.transitionFlipFromLeft], animations: { 
                                    cardView.isFaceUp = false
                                }) { (position) in
                                    self.cardBehavior.addItem(cardView)
                                }
                            }
                        }
                    } else {
                        if !chosenCardView.isFaceUp {
                            self.cardBehavior.addItem(chosenCardView)
                        }
                    }
                }
            }
            
        default:
            break
        }
    }
    
}





























