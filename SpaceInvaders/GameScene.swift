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
let kInvaderSize = CGSize(width: 24, height: 16)
let kShipSize = CGSize(width:30, height:16)
let kSceneHeightOffset: CGFloat = 104.0
let kInvaderGridSpacing = CGSize(width: 12, height: 12)
let kInvaderRowCount = 6
let kInvaderColCount = 6
let kInvaderName = "invader"
let kShipName = "ship"
let kScoreHudName = "scoreHud"
let kHealthHudName = "healthHud"
let kTimePerMove: CFTimeInterval = 1.0/3.0
let kShipFiredBulletName = "shipFiredBullet"
let kInvaderFiredBulletName = "invaderFiredBullet"
let kBulletSize = CGSize(width:4, height: 8)
let kInvaderCategory: UInt32 = 0x1 << 0
let kShipFiredBulletCategory: UInt32 = 0x1 << 1
let kShipCategory: UInt32 = 0x1 << 2
let kSceneEdgeCategory: UInt32 = 0x1 << 3
let kInvaderFiredBulletCategory: UInt32 = 0x1 << 4
let kMinInvaderBottomHeight: CGFloat = 32.0 + kInsetHeight
let kInsetWidth  = CGFloat(90 / 2)
let kInsetHeight = CGFloat(60 / 2)

class GameScene: SKScene, SKPhysicsContactDelegate {

    weak var endSceneDelegate: EndSceneDelegate? = nil
    var score: Int = 0
    var shipHealth: Float = 1.0
    var gameRunning: Bool = false

    var contentCreated: Bool = false
    var invaderMovementDirection: InvaderMovementDirection = .Right
    var timeOfLastMove: CFTimeInterval = 0.0
    var ship: SKSpriteNode? { return childNodeWithName(kShipName) as? SKSpriteNode }
    var contacts: [SKPhysicsContact] = []

    // MARK: - Configure game.

    func loadInvaderTexturesOfType(invaderType: InvaderType) -> [SKTexture] {

        let prefix: String

        switch(invaderType) {

        case .A:
            prefix = "InvaderA"
        case .B:
            prefix = "InvaderB"
        case .C:
            prefix = "InvaderC"
        }
        return [
            SKTexture(imageNamed: String(format: "%@_00.png", prefix)),
            SKTexture(imageNamed: String(format: "%@_01.png", prefix))
        ]
    }

    func makeInvaderOfType(invaderType: InvaderType) -> SKNode {

        let textures = loadInvaderTexturesOfType(invaderType)
        let invader = SKSpriteNode(texture: textures[0])
        let physicsBody = SKPhysicsBody(rectangleOfSize: invader.frame.size)

        physicsBody.dynamic = false
        physicsBody.categoryBitMask = kInvaderCategory
        physicsBody.contactTestBitMask = 0x0
        physicsBody.collisionBitMask = 0x0

        invader.physicsBody = physicsBody
        invader.name = kInvaderName
        invader.runAction(
            SKAction.repeatActionForever(
                SKAction.animateWithTextures(textures, timePerFrame: kTimePerMove)))
        return invader
    }

    func setupInvaders() {

        let baseOrigin = CGPoint(
            x: (size.width + kInvaderGridSpacing.width) / 2.0 - 3 * (kInvaderSize.width + kInvaderGridSpacing.width),
            y: 2.0/3.0 * size.height - (kInvaderSize.height + kInvaderGridSpacing.height) * 7
        )
        for row in 1...kInvaderRowCount {

            let invaderType: InvaderType

            switch row % 3 {

            case 0: invaderType = .A
            case 1: invaderType = .B
            case 2: invaderType = .C
            default: invaderType = .A
            }

            let invaderPositionY = CGFloat(row) * (kInvaderSize.height * 2) + baseOrigin.y
            var invaderPosition = CGPoint(x:baseOrigin.x, y:invaderPositionY)

            for _ in 1...kInvaderColCount {

                let invader = makeInvaderOfType(invaderType)
                invader.position = invaderPosition
                addChild(invader)

                invaderPosition = CGPoint(
                    x: invaderPosition.x + kInvaderSize.width + kInvaderGridSpacing.width,
                    y: invaderPositionY
                )
            }
        }
    }

    func setupShip() {

        let ship = makeShip()
        ship.position = CGPoint(
            x: size.width / 2.0,
            y: kShipSize.height / 2.0 + kInsetHeight
        )
        addChild(ship)
    }

    func makeShip() -> SKNode {

        let ship = SKSpriteNode(imageNamed: "Ship.png")
        let physicsBody = SKPhysicsBody(rectangleOfSize: ship.frame.size)

        physicsBody.dynamic = true
        physicsBody.affectedByGravity = false
        physicsBody.mass = 0.02
        physicsBody.categoryBitMask = kShipCategory
        physicsBody.contactTestBitMask = 0x0
        physicsBody.collisionBitMask = kSceneEdgeCategory

        ship.physicsBody = physicsBody
        ship.name = kShipName

        return ship
    }

    func setupHud() {

        let scoreLabel = SKLabelNode(fontNamed: "Courier")

        scoreLabel.name = kScoreHudName
        scoreLabel.fontSize = 25
        scoreLabel.fontColor = SKColor.greenColor()
        scoreLabel.text = String(format: "Score: %04u", 0)
        scoreLabel.position = CGPoint(
            x: frame.size.width / 2,
            y: size.height - (kInsetHeight + scoreLabel.frame.size.height/2)
        )
        addChild(scoreLabel)

        let healthLabel = SKLabelNode(fontNamed: "Courier")

        healthLabel.name = kHealthHudName
        healthLabel.fontSize = 25
        healthLabel.fontColor = SKColor.redColor()
        healthLabel.text = String(format: "Health: %.1f%%", shipHealth * 100.0)
        healthLabel.position = CGPoint(
            x: frame.size.width / 2,
            y: size.height - (80 + healthLabel.frame.size.height/2)
        )
        addChild(healthLabel)
    }

    func makeBulletOfType(bulletType: BulletType) -> SKNode {

        let physicsBody = SKPhysicsBody(rectangleOfSize: kBulletSize)

        physicsBody.dynamic = true
        physicsBody.affectedByGravity = false
        physicsBody.collisionBitMask = 0x0

        let bullet: SKNode

        switch bulletType {

        case .ShipFired:
            bullet = SKSpriteNode(color: SKColor.greenColor(), size: kBulletSize)
            bullet.name = kShipFiredBulletName

            physicsBody.categoryBitMask = kShipFiredBulletCategory
            physicsBody.contactTestBitMask = kInvaderCategory

        case .InvaderFired:
            bullet = SKSpriteNode(color: SKColor.magentaColor(), size: kBulletSize)
            bullet.name = kInvaderFiredBulletName

            physicsBody.categoryBitMask = kInvaderFiredBulletCategory
            physicsBody.contactTestBitMask = kShipCategory
        }
        bullet.physicsBody = physicsBody

        return bullet
    }

    func startGame() -> Bool {

        setupInvaders()
        setupShip()
        resetShipHealth()

        return true
    }

    func createContent() -> Bool {

        physicsBody = SKPhysicsBody(edgeLoopFromRect: frame)
        physicsBody?.categoryBitMask = kSceneEdgeCategory

        setupHud()

        return true
    }
    
    override func didMoveToView(view: SKView) {

        if !contentCreated {

            backgroundColor = SKColor.blackColor()
            physicsWorld.contactDelegate = self
            contentCreated = createContent()
        }
        configureRecognizers()
        gameRunning = startGame()
    }

    // MARK: - Update methods.

    func adjustScoreBy(points: Int) {

        score += points

        if let label = childNodeWithName(kScoreHudName) as? SKLabelNode {

            label.text = String(format: "Score: %04u", score)
        }
    }

    func resetShipHealth() {

        shipHealth = 1.0

        if let label = childNodeWithName(kHealthHudName) as? SKLabelNode {

            label.text = String(format: "Health: %.1f%%", shipHealth * 100)
        }
    }
    
    func adjustShipHealthBy(healthAdjustment: Float) {

        shipHealth = max(shipHealth + healthAdjustment, 0)

        if let label = childNodeWithName(kHealthHudName) as? SKLabelNode {
        
            label.text = String(format: "Health: %.1f%%", shipHealth * 100)
        }
    }

    func processContactsForUpdate(currentTime: CFTimeInterval) {

        while let contact = contacts.first {

            handleContact(contact)
            contacts.removeFirst()
        }
    }

    func moveInvadersForUpdate(currentTime: CFTimeInterval) {

        guard currentTime - timeOfLastMove >= kTimePerMove else { return }
        
        determineInvaderMovementDirection()

        enumerateChildNodesWithName(kInvaderName) { node, stop in

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
        }
        timeOfLastMove = currentTime
    }

    func determineInvaderMovementDirection() {

        var proposedMovementDirection = invaderMovementDirection

        enumerateChildNodesWithName(kInvaderName) { node, stop in

            switch self.invaderMovementDirection {

            case .Right:
                if CGRectGetMaxX(node.frame) >= node.scene!.size.width - 1.0 {
                    proposedMovementDirection = .DownThenLeft
                    stop.memory = true
                }
            case .Left:
                if CGRectGetMinX(node.frame) <= 1.0 {
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
    
    func fireInvaderBulletsForUpdate(currentTime: CFTimeInterval) {

        guard nil == childNodeWithName(kInvaderFiredBulletName) else { return }

        var allInvaders: [SKNode] = []

        enumerateChildNodesWithName(kInvaderName) { node, stop in

            allInvaders.append(node)
        }
        if !allInvaders.isEmpty {

            let allInvadersIndex = Int(arc4random_uniform(UInt32(allInvaders.count)))
            let invader = allInvaders[allInvadersIndex]

            let bullet = makeBulletOfType(.InvaderFired)
            bullet.position = CGPoint(
                x: invader.position.x,
                y: invader.position.y - invader.frame.size.height / 2 + bullet.frame.size.height / 2
            )
            let destination = CGPoint(
                x: invader.position.x,
                y: -(bullet.frame.size.height / 2)
            )
            fireBullet(bullet, toDestination: destination, withDuration: 2.0, andSoundFileName: "InvaderBullet.wav")
        }
    }
    
    override func update(currentTime: CFTimeInterval) {

        guard !isGameOver() else { endGame(); return }

        processContactsForUpdate(currentTime)
        moveInvadersForUpdate(currentTime)
        fireInvaderBulletsForUpdate(currentTime)
    }

    // MARK: - User interaction methods.

    func moveShipRight() {

        ship?.physicsBody?.applyForce(CGVectorMake(50.0, 0))
    }

    func moveShipLeft() {

        ship?.physicsBody?.applyForce(CGVectorMake(-50.0, 0))
    }

    func fireBullet(bullet: SKNode, toDestination destination:CGPoint, withDuration duration:CFTimeInterval, andSoundFileName soundName: String) {

        let bulletAction = SKAction.sequence([
            SKAction.moveTo(destination, duration: duration),
            SKAction.waitForDuration(3.0/60.0),
            SKAction.removeFromParent()
        ])
        let soundAction = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)

        bullet.runAction(SKAction.group([bulletAction, soundAction]))
        addChild(bullet)
    }

    func fireShipBullets() {

        guard nil == childNodeWithName(kShipFiredBulletName), let ship = ship else { return }

        let bullet = makeBulletOfType(.ShipFired)

        bullet.position = CGPoint(
            x: ship.position.x,
            y: ship.position.y + ship.frame.size.height - bullet.frame.size.height / 2
        )
        let destination = CGPoint(
            x: ship.position.x,
            y: frame.size.height + bullet.frame.size.height / 2
        )
        fireBullet(bullet, toDestination: destination, withDuration: 1.0, andSoundFileName: "ShipBullet.wav")
    }

    // MARK: - SKPhysicsContactDelegate

    func didBeginContact(contact: SKPhysicsContact) {

        contacts.append(contact)
    }

    func handleContact(contact: SKPhysicsContact) {

        // Ensure you haven't already handled this contact and removed its nodes
        guard let nodeA = contact.bodyA.node, nodeB = contact.bodyB.node
            where nodeA.parent != nil && nodeB.parent != nil else { return }

        let names: Set<String> = [nodeA.name ?? "", nodeB.name ?? ""]

        if names.contains(kShipName) && names.contains(kInvaderFiredBulletName) {

            // Invader bullet hit a ship
            runAction(SKAction.playSoundFileNamed("ShipHit.wav", waitForCompletion: false))
            adjustShipHealthBy(-0.334)

            if shipHealth <= 0.0 {

                nodeA.removeFromParent()
                nodeB.removeFromParent()
            }
            else if let ship = ship {

                ship.alpha = CGFloat(shipHealth)

                if nodeA == ship {

                    nodeB.removeFromParent()
                }
                else { nodeA.removeFromParent() }
            }
        }
        else if names.contains(kInvaderName) && names.contains(kShipFiredBulletName) {

            // Ship bullet hit an invader
            runAction(SKAction.playSoundFileNamed("InvaderHit.wav", waitForCompletion: false))
            adjustScoreBy(100)

            nodeA.removeFromParent()
            nodeB.removeFromParent()
        }
    }

    // MARK: - End game methods.

    func isGameOver() -> Bool {

        if let _ = ship, _ = childNodeWithName(kInvaderName) {

            var invaderTooLow = false

            enumerateChildNodesWithName(kInvaderName) { node, stop in

                if CGRectGetMinY(node.frame) <= kMinInvaderBottomHeight {

                    invaderTooLow = true
                    stop.memory = true
                }
            }
            return invaderTooLow
        }
        return true
    }

    func endGame() {

        if gameRunning {

            gameRunning = false

            while let node = childNodeWithName(kInvaderName) {

                node.removeFromParent()
            }
            ship?.removeFromParent()
            removeRecognizers()

            endSceneDelegate?.endScene(self)
        }
    }

    // MARK: - Configure recognizers.

    var recognizers: [UIGestureRecognizer] = []

    func configureRecognizers() {

        let tapRecognizer = UITapGestureRecognizer(target: self, action: "selectTarget:")

        let swipeRightRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeRightTarget:")
        swipeRightRecognizer.direction = .Right

        let swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeLeftTarget:")
        swipeLeftRecognizer.direction = .Left

        recognizers = [tapRecognizer, swipeRightRecognizer, swipeLeftRecognizer]

        for recognizer in recognizers {

            view?.addGestureRecognizer(recognizer)
        }
    }

    func removeRecognizers() {

        for recognizer in recognizers {

            recognizer.view?.removeGestureRecognizer(recognizer)
        }
        recognizers = []
    }

    func swipeRightTarget(recognizer: UISwipeGestureRecognizer) {

        log.debug("")

        moveShipRight()
    }

    func swipeLeftTarget(recognizer: UISwipeGestureRecognizer) {

        log.debug("")

        moveShipLeft()
    }
    
    func selectTarget(recognizer: UITapGestureRecognizer) {
        
        log.debug("")
        
        fireShipBullets()
    }
}
