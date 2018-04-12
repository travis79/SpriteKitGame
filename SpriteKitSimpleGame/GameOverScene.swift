//
//  GameOverScene.swift
//  SpriteKitSimpleGame
//
//  Created by Long, Travis on 3/28/18.
//  Copyright © 2018 Long, Travis. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    let userDefaults = UserDefaults.standard
    var totalDeaths = 0
    var totalHits = 0
    var totalShots = 0
    
    init(size: CGSize, won: Bool) {
        super.init(size: size)
        
        totalDeaths = userDefaults.integer(forKey: "TOTAL_DEATHS")
        totalHits = userDefaults.integer(forKey: "TOTAL_HITS")
        totalShots = userDefaults.integer(forKey: "TOTAL_SHOTS")
        
        backgroundColor = SKColor.white
        
        let message = won ? "You Won!" : "You Lose!"
        
        let emitter = SKEmitterNode(fileNamed: "BloodParticle")
        emitter?.targetNode = self
        
        let label = SKLabelNode(fontNamed: "System")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.black
        label.position = CGPoint(x: size.width/2, y: size.height/2)
//        label.addChild(emitter!)
        addChild(label)
        
        let killRatioLabel = SKLabelNode(fontNamed: "System")
        var killRatio = 0.0
        if (totalDeaths != 0) {
            killRatio = Double(totalHits) / Double(totalDeaths)
        }
        killRatioLabel.text = "Kills to Deaths: \(String(format: "%.02f", killRatio))"
        killRatioLabel.fontSize = 20
        killRatioLabel.fontColor = SKColor.black
        killRatioLabel.position = CGPoint(x: size.width / 2,
                                          y: label.position.y - killRatioLabel.frame.height - 10)
        addChild(killRatioLabel)
        
        let accuracyLabel = SKLabelNode(fontNamed: "System")
        var accuracy = 0.0
        if (totalShots != 0) {
            accuracy = Double(totalHits) / Double(totalShots)
        }
        accuracyLabel.text = "Accuracy: \(String(format: "%.02f", accuracy))"
        accuracyLabel.fontSize = 20
        accuracyLabel.fontColor = SKColor.black
        accuracyLabel.position = CGPoint(x: size.width / 2,
                                          y: killRatioLabel.position.y - accuracyLabel.frame.height)
        accuracyLabel.addChild(emitter!)
        addChild(accuracyLabel)
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: 3.0),
            SKAction.run() {
                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                let scene = GameScene(size: size)
                self.view?.presentScene(scene, transition: reveal)
            }
        ]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
