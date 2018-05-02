//
//  GameScene.swift
//  SpriteKitSimpleGame
//
//  Created by Long, Travis on 3/28/18.
//  Copyright © 2018 Long, Travis. All rights reserved.
//

import SpriteKit
import GameplayKit

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

struct PhysicsCategory {
    static let None: UInt32 = 0
    static let All: UInt32 = UInt32.max
    static let Monster: UInt32 = 0b1
    static let Projectile: UInt32 = 0b10
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    let player = SKSpriteNode(imageNamed: "player")
    var monstersDestroyed = 0
    var highScore = 0
    var highScoreLabel: SKLabelNode!
    var scoreLabel: SKLabelNode!
    let userDefaults = UserDefaults.standard
    var backgroundNode1: SKSpriteNode!
    var backgroundNode2: SKSpriteNode!

    override func didMove(to view: SKView) {
        backgroundNode1 = SKSpriteNode(imageNamed: "backgroundImg")
        backgroundNode2 = SKSpriteNode(imageNamed: "backgroundImg")
        
        backgroundNode1.position = CGPoint(x: size.width/2, y: size.height / 2)
        backgroundNode2.position = CGPoint(
            x: backgroundNode1.position.x + backgroundNode1.size.width,
            y: size.height / 2)
        
        backgroundNode1.zPosition = -100
        backgroundNode2.zPosition = -100
        
        let bgAnimation = SKAction.moveBy(x: -100.0, y: 0, duration: 1.0)
        let checkBg1 = SKAction.run {
            if self.backgroundNode1.position.x <= -(self.backgroundNode1.size.width / 2) {
                self.backgroundNode1.position = CGPoint(
                    x: self.backgroundNode2.position.x + self.backgroundNode2.size.width,
                    y: self.size.height / 2)
            }
        }
        let checkBg2 = SKAction.run {
            if self.backgroundNode2.position.x <= -(self.backgroundNode2.size.width / 2) {
                self.backgroundNode2.position = CGPoint(
                    x: self.backgroundNode1.position.x + self.backgroundNode1.size.width,
                    y: self.size.height / 2)
            }
        }
        
        let bg1Animation = SKAction.repeatForever(SKAction.sequence([bgAnimation, checkBg1]))
        let bg2Animation = SKAction.repeatForever(SKAction.sequence([bgAnimation, checkBg2]))
        
        backgroundNode1.run(bg1Animation)
        backgroundNode2.run(bg2Animation)
        
        addChild(backgroundNode1)
        addChild(backgroundNode2)
        
        backgroundColor = SKColor.darkGray
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        addChild(player)
        
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        
        highScore = userDefaults.integer(forKey: "HI_SCORE")
        
        highScoreLabel = SKLabelNode(fontNamed: "System")
        highScoreLabel.fontColor = SKColor.black
        highScoreLabel.fontSize = 30
        highScoreLabel.zPosition = 100
        highScoreLabel.text = "High Score: \(highScore)"
        highScoreLabel.position = CGPoint(x: highScoreLabel.frame.width / 2 + 5,
                                          y: self.size.height - highScoreLabel.frame.height / 2 - 10)
        addChild(highScoreLabel)
        
        scoreLabel = SKLabelNode(fontNamed: "System")
        scoreLabel.fontColor = SKColor.black
        scoreLabel.fontSize = 30
        scoreLabel.zPosition = 100
        scoreLabel.text = "Score: \(monstersDestroyed)"
        scoreLabel.position = CGPoint(x: self.size.width - scoreLabel.frame.width / 2 - 5,
                                      y: self.size.height - scoreLabel.frame.height / 2 - 10)
        addChild(scoreLabel)
        
        run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run(addMonster),
                               SKAction.wait(forDuration: 1.0)
                ])
        ))
        
        let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)       
        
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func addMonster() {
        let monster = SKSpriteNode(imageNamed: "monster")
        
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size)
        monster.physicsBody?.isDynamic = true
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        let actualY = random(min: monster.size.height/2, max: size.height - monster.size.height/2)
        
        monster.position = CGPoint(x: size.width + monster.size.width/2, y: actualY)
        
        addChild(monster)
        
        let actualDuration = random(min: CGFloat(4.0), max: CGFloat(8.0))
        
        let actionMove = SKAction.move(to: CGPoint(x: -monster.size.width/2, y: actualY), duration: TimeInterval(actualDuration))
        
        let actionMoveDone = SKAction.removeFromParent()
        
        let loseAction = SKAction.run() {
            if self.monstersDestroyed > self.highScore {
                self.highScore = self.monstersDestroyed
                self.userDefaults.set(self.highScore, forKey: "HI_SCORE")
                self.userDefaults.synchronize()
                self.highScoreLabel.text = "High Score: \(self.highScore)"
            }
            
            let deaths = self.userDefaults.integer(forKey: "TOTAL_DEATHS")
            self.userDefaults.set(deaths + 1, forKey: "TOTAL_DEATHS")
            
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOverScene = GameOverScene(size: self.size, won: false)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
        
        monster.run(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        run(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
        
        guard let touch = touches.first else {
            return
        }
        
        let touchLocation = touch.location(in: self)
        
        let projectile = SKSpriteNode(imageNamed: "projectile")
        
        projectile.position = player.position
        
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.isDynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
//        let emitter = SKEmitterNode(fileNamed: "ProjectileParticle")
//        emitter?.targetNode = self
//        projectile.addChild(emitter!)
        
        let offset = touchLocation - projectile.position
        
        if (offset.x < 0) {
            return
        }
        
        let shots = userDefaults.integer(forKey: "TOTAL_SHOTS")
        userDefaults.set(shots + 1, forKey: "TOTAL_SHOTS")
        
        addChild(projectile)
        
        let direction = offset.normalized()
        
        let shootAmount = direction * 1000
        
        let realDest = shootAmount + projectile.position
        
        let actionMove = SKAction.move(to: realDest, duration: 2.0)
        let actionRotate = SKAction.rotate(byAngle: 360, duration: 1.0)
        let actionRotateForever = SKAction.repeatForever(actionRotate)
        let totalMovement = SKAction.group([actionMove, actionRotateForever])
        let actionMoveDone = SKAction.removeFromParent()
        projectile.run(SKAction.sequence([totalMovement, actionMoveDone]))
    }
    
    func projectileDidCollideWithMonster(projectile: SKSpriteNode, monster: SKSpriteNode) {
        print("Hit")
        projectile.removeFromParent()
        
        let deathEmitter = SKEmitterNode(fileNamed: "BloodParticle")
        deathEmitter?.position = monster.position
        let emitterAction = SKAction.fadeOut(withDuration: 1.0)
        deathEmitter?.run(SKAction.sequence([emitterAction, SKAction.removeFromParent()]))
        addChild(deathEmitter!)
        
        monster.removeFromParent()
        
        monstersDestroyed += 1
        
        let hits = userDefaults.integer(forKey: "TOTAL_HITS")
        userDefaults.set(hits + 1, forKey: "TOTAL_HITS")
        
        scoreLabel.text = "Score: \(monstersDestroyed)"
        
        if monstersDestroyed >= 30 {
            if self.monstersDestroyed > self.highScore {
                self.highScore = self.monstersDestroyed
                self.userDefaults.set(self.highScore, forKey: "HI_SCORE")
                self.userDefaults.synchronize()
                self.highScoreLabel.text = "High Score: \(self.highScore)"
            }
            
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOverScene = GameOverScene(size: self.size, won: true)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
            if let monster = firstBody.node as? SKSpriteNode,
                let projectile = secondBody.node as? SKSpriteNode {
                projectileDidCollideWithMonster(projectile: projectile, monster: monster)
            }
        }
    }
}
