//
//  GameScene.swift
//  project14
//
//  Created by Ivan Pavic on 6.2.22..
//

import SpriteKit

class GameScene: SKScene {
    var slots = [WhackSlot]()
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var popUpTime = 0.85
    var roundCounter = 0
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "backgroundArctic")
        background.blendMode = .replace
        background.position = CGPoint(x: 512, y: 384)
        background.zPosition = -1
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 400, y: 735)
        scoreLabel.fontSize = 48
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        for i in 0..<4 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 310))}
        for i in 0..<3 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 220))}
        for i in 0..<4 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 130))}
        for i in 0..<3 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 40))}
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.createEnemy()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        for node in tappedNodes {
            guard let whackSlot = node.parent?.parent as? WhackSlot else { continue }
            if !whackSlot.isVisible { continue }
            if whackSlot.isHIt { continue }
            whackSlot.hit()
            
            if node.name == "charFriend" {
                score -= 5
                whackSlot.charNode.xScale = 1.15
                whackSlot.charNode.yScale = 1.15
                run(SKAction.playSoundFileNamed("whackBad", waitForCompletion: false))
                
            } else if node.name == "charEnemy" {
                score += 1
                whackSlot.charNode.xScale = 0.85
                whackSlot.charNode.yScale = 0.85
                run(SKAction.playSoundFileNamed("whack", waitForCompletion: false))
            }
        }
    }
    
    func createSlot (at position: CGPoint) {
        let slot = WhackSlot()
        slot.configure(at: position)
        addChild(slot)
        slots.append(slot)
    }
    
    func createEnemy () {
        roundCounter += 1
        if roundCounter >= 35 {
            for slot in slots {
                slot.hide()
            }
            
            let gameOver = SKSpriteNode(imageNamed: "gameOver")
            gameOver.name = "gameOver"
            gameOver.zPosition = 1
            gameOver.position = CGPoint(x: 512, y: 600)
            gameOver.run(SKAction.playSoundFileNamed("gameOver", waitForCompletion: false))
            addChild(gameOver)
            
            let scoreFinal = SKSpriteNode(imageNamed: "finalScore")
            scoreFinal.position = CGPoint(x: 511, y: 520)
            scoreFinal.zPosition = 1
            scoreFinal.name = "finalScore"
            addChild(scoreFinal)
            
            let finalScore = SKLabelNode()
            let shadow = NSShadow()
            shadow.shadowColor = UIColor.black
            shadow.shadowBlurRadius = 5
            shadow.shadowOffset = CGSize(width: 0.5, height: 5)
            finalScore.attributedText = NSAttributedString(string: "\(score)", attributes:[
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.font: UIFont(name: "Chalkboard SE Bold", size: 44) ?? UIFont.systemFont(ofSize: 44),
                NSAttributedString.Key.shadow: shadow
            ])
            finalScore.zPosition = 1
            finalScore.position = CGPoint(x: 508 + scoreFinal.size.width / 2, y: 510)
            finalScore.name = "finalScore"
            addChild(finalScore)
            
            let ac = UIAlertController(title: "New Game", message: "Try again?", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: newGame))
            self.view?.window?.rootViewController?.present(ac, animated: true)
            
            return
        }
        
        popUpTime *= 0.991
        
        slots.shuffle()
        slots[0].show(hideTime: popUpTime)
        
        if Int.random(in: 0...12) > 4 {slots[1].show(hideTime: popUpTime)}
        if Int.random(in: 0...12) > 6 {slots[2].show(hideTime: popUpTime)}
        if Int.random(in: 0...12) > 8 {slots[3].show(hideTime: popUpTime)}
        if Int.random(in: 0...12) > 10 {slots[4].show(hideTime: popUpTime)}
        if Int.random(in: 0...12) > 11 {slots[5].show(hideTime: popUpTime)}
        
        let minDelay = popUpTime / 2
        let maxDelay = popUpTime * 1.5
        let delay = Double.random(in: minDelay...maxDelay)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.createEnemy()
        }
    }
    
    func newGame(action: UIAlertAction) {
        popUpTime = 0.85
        for slot in slots {
            slot.show(hideTime: popUpTime)
        }
        score = 0
        roundCounter = 0
        
        for child in children {
            if child.name == "finalScore" || child.name == "gameOver" {
                child.removeFromParent()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in self?.createEnemy() }
    }
}
