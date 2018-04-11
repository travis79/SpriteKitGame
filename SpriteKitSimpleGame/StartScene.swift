//
//  StartScene.swift
//  SpriteKitSimpleGame
//
//  Created by Long, Travis on 4/4/18.
//  Copyright © 2018 Long, Travis. All rights reserved.
//

import Foundation
import SpriteKit

class StartScene: SKScene {
    var startButton: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        
        startButton = SKSpriteNode(imageNamed: "startButton")
        startButton.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(startButton)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.location(in: startButton)
        if touchLocation.x > -startButton.size.width / 2
            && touchLocation.x < startButton.size.width / 2
            && touchLocation.y > -startButton.size.height / 2
            && touchLocation.y < startButton.size.height / 2 {
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameScene = GameScene(size: self.size)
            self.view?.presentScene(gameScene, transition: reveal)
        }
    }
}
