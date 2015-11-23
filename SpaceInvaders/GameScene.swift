//
//  GameScene.swift
//  SpaceInvaders
//
//  Created by Andrew Donoho on 11/22/15.
//  Copyright (c) 2015 Donoho Design Group, LLC. All rights reserved.
//

import SpriteKit

enum InvaderType {
    case A
    case B
    case C
}

enum InvaderMovementDirection {
    case Right
    case Left
    case DownThenRight
    case DownThenLeft
    case None
}

enum BulletType {
    case ShipFired
    case InvaderFired
}

let kInvaderSize = CGSize(width:24, height:16)
let kShipSize = CGSize(width:30, height:16)

let kInvaderName = "invader"

let kShipName = "ship"

let kScoreHudName = "scoreHud"
let kHealthHudName = "healthHud"

let kShipFiredBulletName = "shipFiredBullet"
let kInvaderFiredBulletName = "invaderFiredBullet"
let kBulletSize = CGSize(width:4, height: 8)



class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let kMinInvaderBottomHeight: Float = 32.0
    var gameEnding: Bool = false
    var score: Int = 0
    var shipHealth: Float = 1.0
    var contactQueue = Array<SKPhysicsContact>()
    
    let kInvaderGridSpacing = CGSize(width:12, height:12)
    let kInvaderRowCount = 6
    let kInvaderColCount = 6

    var contentCreated: Bool = false
    
    var invaderMovementDirection: InvaderMovementDirection = .Right
    var timeOfLastMove: CFTimeInterval = 0.0
    let timePerMove: CFTimeInterval = 0.3
    
    var ship : SKSpriteNode? { return childNodeWithName(kShipName) as? SKSpriteNode }
    
    var tapQueue: Array<Int> = []
    
    let kInvaderCategory: UInt32 = 0x1 << 0
    let kShipFiredBulletCategory: UInt32 = 0x1 << 1
    let kShipCategory: UInt32 = 0x1 << 2
    let kSceneEdgeCategory: UInt32 = 0x1 << 3
    let kInvaderFiredBulletCategory: UInt32 = 0x1 << 4
    
    func  createContent() -> Bool {
        physicsBody = SKPhysicsBody(edgeLoopFromRect: frame)
        physicsBody!.categoryBitMask = kSceneEdgeCategory
        setupInvaders()
        setupShip()
        setupHud()
        
        backgroundColor = SKColor.blackColor()
        
        return true
    }
    
    func loadInvaderTexturesOfType(invaderType: InvaderType) -> Array<SKTexture> {
        var prefix: String
        
        switch(invaderType) {
        case .A:
            prefix = "InvaderA"
        case .B:
            prefix = "InvaderB"
        case .C:
            prefix = "InvaderC"
        }
        
        return [SKTexture(imageNamed: String(format: "%@_00.png", prefix)),
            SKTexture(imageNamed: String(format: "%@_01.png", prefix))]
    }
    
    func makeInvaderOfType(invaderType: InvaderType) -> SKNode {
        
        let invaderTextures = self.loadInvaderTexturesOfType(invaderType)
        
        let invader = SKSpriteNode(texture: invaderTextures[0])
        invader.name = kInvaderName
        invader.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(invaderTextures, timePerFrame: self.timePerMove)))
        
        // invaders' bitmasks setup
        invader.physicsBody = SKPhysicsBody(rectangleOfSize: invader.frame.size)
        invader.physicsBody!.dynamic = false
        invader.physicsBody!.categoryBitMask = kInvaderCategory
        invader.physicsBody!.contactTestBitMask = 0x0
        invader.physicsBody!.collisionBitMask = 0x0
        
        return invader
    }
    
    func setupInvaders() {
        let baseOrigin = CGPoint(x: size.width/3, y: 180)
        
        for row in 1...kInvaderRowCount {
            var invaderType : InvaderType
            
            switch row % 3 {
            case 0:
                invaderType = .A
            case 1:
                invaderType = .B
            case 2:
                invaderType = .C
            default:
                invaderType = .A
            }
            
            let invaderPositionY = CGFloat(row) * (kInvaderSize.height * 2) + baseOrigin.y
            var invaderPosition = CGPoint(x: baseOrigin.x, y: invaderPositionY)
            
            for _ in 1...kInvaderColCount {
                let invader = makeInvaderOfType(invaderType)
                invader.position = invaderPosition
                addChild(invader)
                
                invaderPosition = CGPoint(
                    x: invaderPosition.x + kInvaderSize.width + kInvaderGridSpacing.width,
                    y: invaderPositionY)
                
            }
        }
    }
    
    func setupShip() {
        let ship = makeShip()
        ship.position = CGPoint(x: size.width/2.0, y: kShipSize.height/2.0)
        addChild(ship)
        
    }
    
    func makeShip() -> SKNode {
        let ship = SKSpriteNode(imageNamed: "Ship.png")
        ship.name = kShipName
        let physicsBody = SKPhysicsBody(rectangleOfSize: ship.frame.size)
        physicsBody.dynamic = true
        physicsBody.affectedByGravity = false
        physicsBody.mass = 0.02
        ship.physicsBody = physicsBody
        
        ship.physicsBody!.categoryBitMask = kShipCategory
        ship.physicsBody!.contactTestBitMask = 0x0
        ship.physicsBody!.collisionBitMask = kSceneEdgeCategory
        
        return ship
    }
    
    func setupHud() {
        // add score label
        let scoreLabel = SKLabelNode( fontNamed: "Courier")
        scoreLabel.name = kScoreHudName
        scoreLabel.fontSize = 25
        scoreLabel.fontColor = SKColor.greenColor()
        scoreLabel.text = String(format: "Score: %04u", 0)
        scoreLabel.position = CGPoint(x: frame.size.width / 2, y: size.height - (40 + scoreLabel.frame.size.height/2))
        addChild(scoreLabel)
        
        // add health label
        let healthLabel = SKLabelNode(fontNamed: "Courier")
        healthLabel.name = kHealthHudName
        healthLabel.fontSize = 25
        healthLabel.fontColor = SKColor.redColor()
        healthLabel.text = String(format: "Health: %.1f%%", self.shipHealth * 100.0)
        healthLabel.position = CGPoint(x: frame.size.width / 2, y: size.height - (80 + healthLabel.frame.size.height/2))
        addChild(healthLabel)
    }
    
    func makeBulletOfType(bulletType: BulletType) -> SKNode {
        let bullet: SKNode
        
        switch bulletType {
        case .ShipFired:
            bullet = SKSpriteNode(color: SKColor.greenColor(), size: kBulletSize)
            bullet.name = kShipFiredBulletName
            bullet.physicsBody = SKPhysicsBody(rectangleOfSize: bullet.frame.size)
            bullet.physicsBody!.dynamic = true
            bullet.physicsBody!.affectedByGravity = false
            bullet.physicsBody!.categoryBitMask = kShipFiredBulletCategory
            bullet.physicsBody!.contactTestBitMask = kInvaderCategory
            bullet.physicsBody!.collisionBitMask = 0x0
        case .InvaderFired:
            bullet = SKSpriteNode(color: SKColor.magentaColor(), size: kBulletSize)
            bullet.name = kInvaderFiredBulletName
            bullet.physicsBody = SKPhysicsBody(rectangleOfSize: bullet.frame.size)
            bullet.physicsBody!.dynamic = true
            bullet.physicsBody!.affectedByGravity = false
            bullet.physicsBody!.categoryBitMask = kInvaderFiredBulletCategory
            bullet.physicsBody!.contactTestBitMask = kShipCategory
            bullet.physicsBody!.collisionBitMask = 0x0
        }
        
        return bullet
    }
    
    override func didMoveToView(view: SKView) {
        userInteractionEnabled = true
        physicsWorld.contactDelegate = self
        if !contentCreated {
            contentCreated = createContent()
        }
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        moveInvadersForUpdate(currentTime)
        processUserTapsForUpdate(currentTime)
        fireInvaderBulletsForUpdate(currentTime)
        processContactsForUpdate(currentTime)
        
        if self.isGameOver() {
            self.endGame()
        }

    }
    
    func moveLeft() {
        ship?.physicsBody!.applyForce(CGVectorMake(-100.0, 0))
    }
    
    func moveRight() {
        ship?.physicsBody!.applyForce(CGVectorMake(100, 0))
    }
    
    func fireMissle() {
        self.tapQueue.append(1)
    }
    
    // MARK:  Scene Update Helpers
    func moveInvadersForUpdate( currentTime: CFTimeInterval ) {
        if (currentTime - timeOfLastMove < timePerMove) {
            return
        }
        
        determineInvaderMovementDirection()
        
        enumerateChildNodesWithName(kInvaderName) {
            (node: SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            
            switch self.invaderMovementDirection {
            case .Right:
                node.position = CGPoint(x: node.position.x + 10, y: node.position.y)
            case .Left:
                node.position = CGPoint(x: node.position.x - 10, y: node.position.y)
            case .DownThenLeft, .DownThenRight:
                node.position = CGPoint(x: node.position.x, y: node.position.y - 10)
            case .None:
                break
            }
            self.timeOfLastMove = currentTime
        }
    }
    
    func processUserTapsForUpdate(currentTime: CFTimeInterval) {
        for tapCount in self.tapQueue {
            if tapCount == 1 {
                self.fireShipBullets()
            }
            self.tapQueue.removeAtIndex(0)
        }
    }
    
    func processContactsForUpdate(currentTime: CFTimeInterval) {
        
        for contact in self.contactQueue {
            self.handleContact(contact)
            
            if let index = (self.contactQueue as NSArray).indexOfObject(contact) as Int? {
                self.contactQueue.removeAtIndex(index)
            }
        }
    }
    
    // MARK: Invader Movement Helpers:
    
    func determineInvaderMovementDirection() {
        var proposedMovementDirection: InvaderMovementDirection = invaderMovementDirection
        
        enumerateChildNodesWithName(kInvaderName) { node, stop in
            switch self.invaderMovementDirection {
            case .Right:
                if (CGRectGetMaxX(node.frame) >= node.scene!.size.width - 1.0) {
                    proposedMovementDirection = .DownThenLeft
                    stop.memory = true
                }
            case .Left:
                if (CGRectGetMinX(node.frame) <= 1.0) {
                    proposedMovementDirection = .DownThenRight
                    
                    stop.memory = true
                }
            case .DownThenLeft:
                proposedMovementDirection = .Left
                stop.memory = true
            case .DownThenRight:
                proposedMovementDirection = .Right
                stop.memory = true
            default:
                break
            }
        }
        
        if (proposedMovementDirection != invaderMovementDirection) {
            invaderMovementDirection = proposedMovementDirection
        }
        
    }
    
    //  MARK: Bullet Helpers
    func fireBullet(bullet: SKNode, toDestination destination:CGPoint, withDuration duration:CFTimeInterval, andSoundFileName soundName: String) {
        let bulletAction = SKAction.sequence([SKAction.moveTo(destination, duration: duration), SKAction.waitForDuration(3.0/60.0), SKAction.removeFromParent()])
        let soundAction = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        bullet.runAction(SKAction.group([bulletAction, soundAction]))
        self.addChild(bullet)
    }
    
    func fireShipBullets() {
        let existingBullet = self.childNodeWithName(kShipFiredBulletName)
        if existingBullet == nil {
            if let ship = ship {
                let bullet = self.makeBulletOfType(.ShipFired)
                bullet.position = CGPoint(x: ship.position.x, y: ship.position.y + ship.frame.size.height - bullet.frame.size.height / 2)
                let bulletDestination = CGPoint(x: ship.position.x, y: self.frame.size.height + bullet.frame.size.height / 2)
                self.fireBullet(bullet, toDestination: bulletDestination, withDuration: 1.0, andSoundFileName: "ShipBullet.wav")
            }
        }
    }
    
    func fireInvaderBulletsForUpdate(currentTime: CFTimeInterval) {
        let existingBullet = self.childNodeWithName(kInvaderFiredBulletName)
        if existingBullet == nil {
            var allInvaders = Array<SKNode>()
            
            self.enumerateChildNodesWithName(kInvaderName) {
                node, stop in
                allInvaders.append(node)
            }
            
            if !allInvaders.isEmpty {
                let allInvadersIndex = Int(arc4random_uniform(UInt32(allInvaders.count)))
                let invader = allInvaders[allInvadersIndex]
                let bullet = self.makeBulletOfType(.InvaderFired)
                bullet.position = CGPoint(x: invader.position.x, y: invader.position.y - invader.frame.size.height / 2 + bullet.frame.size.height / 2)
                let bulletDestination = CGPoint(x: invader.position.x, y: -(bullet.frame.size.height / 2))
                self.fireBullet(bullet, toDestination: bulletDestination, withDuration: 2.0, andSoundFileName: "InvaderBullet.wav")
            }
        }
    }
    
    //  MARK: Physics Contact Helpers
    
    func didBeginContact(contact: SKPhysicsContact) {
        if contact as SKPhysicsContact? != nil {
            self.contactQueue.append(contact)
        }
    }
    
    func handleContact(contact: SKPhysicsContact) {
        
        // Ensure you haven't already handled this contact and removed its nodes
        if (contact.bodyA.node?.parent == nil || contact.bodyB.node?.parent == nil) {
            return
        }
        
        let nodeNames = [contact.bodyA.node!.name!, contact.bodyB.node!.name!]
        
        if (nodeNames as NSArray).containsObject(kShipName) && (nodeNames as NSArray).containsObject(kInvaderFiredBulletName) {
            
            // Invader bullet hit a ship
            self.runAction(SKAction.playSoundFileNamed("ShipHit.wav", waitForCompletion: false))
            
            self.adjustShipHealthBy(-0.334)
            
            if self.shipHealth <= 0.0 {
                contact.bodyA.node!.removeFromParent()
                contact.bodyB.node!.removeFromParent()
                
            } else {
                let ship = self.childNodeWithName(kShipName)!
                ship.alpha = CGFloat(self.shipHealth)
                
                if contact.bodyA.node == ship {
                    contact.bodyB.node!.removeFromParent()
                } else {
                    contact.bodyA.node!.removeFromParent()
                }
                
            }
            
        } else if ((nodeNames as NSArray).containsObject(kInvaderName) && (nodeNames as NSArray).containsObject(kShipFiredBulletName)) {
            
            // Ship bullet hit an invader
            self.runAction(SKAction.playSoundFileNamed("InvaderHit.wav", waitForCompletion: false))
            contact.bodyA.node!.removeFromParent()
            contact.bodyB.node!.removeFromParent()
            
            self.adjustScoreBy(100)
        }
    }
    
    // MARK: Hud Helpers
    
    func adjustScoreBy(points: Int) {
        self.score += points
        let score = self.childNodeWithName(kScoreHudName) as! SKLabelNode
        score.text = String(format: "Score: %04u", self.score)
    }
    
    func adjustShipHealthBy(healthAdjustment: Float) {
        self.shipHealth = max(self.shipHealth + healthAdjustment, 0)
        let health = self.childNodeWithName(kHealthHudName) as! SKLabelNode
        health.text = String(format: "Health: %.1f%%", self.shipHealth * 100)
    }
    
    // MARK: Game End Helpers
    
    func isGameOver() -> Bool {
        
        let invader = self.childNodeWithName(kInvaderName)
        var invaderTooLow = false
        
        self.enumerateChildNodesWithName(kInvaderName) {
            node, stop in
            
            if (Float(CGRectGetMinY(node.frame)) <= self.kMinInvaderBottomHeight)   {
                
                invaderTooLow = true
                stop.memory = true
            }
        }
        
        let ship = self.childNodeWithName(kShipName)
        return invader == nil || invaderTooLow || ship == nil
    }
    
    func endGame() {
        if !self.gameEnding {
            self.gameEnding = true
            let gameOverScene: GameOverScene = GameOverScene(size: self.size)
            view!.presentScene(gameOverScene, transition: SKTransition.doorsOpenHorizontalWithDuration(1.0))
        }
    }
    
}
