//
//  GameScene.swift
//  SpaceInvaders
//
//  Created by Andrew Donoho on 11/22/15.
//  Copyright (c) 2015 Donoho Design Group, LLC. All rights reserved.
//

import SpriteKit

//1
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
let kInvaderSize = CGSize(width:24, height:16)
let kShipSize = CGSize(width:30, height:16)

let kInvaderGridSpacing = CGSize(width:12, height:12)
let kInvaderRowCount = 6
let kInvaderColCount = 6
let kInvaderName = "invader"
let kShipName = "ship"
let kScoreHudName = "scoreHud"
let kHealthHudName = "healthHud"

class GameScene: SKScene {

    
    // Private GameScene Properties
    var contentCreated: Bool = false
    // 1
    var invaderMovementDirection: InvaderMovementDirection = .Right
    // 2
    var timeOfLastMove: CFTimeInterval = 0.0
    // 3
    let timePerMove: CFTimeInterval = 0.5
    
    //2
 
    
    // 3

    
    // Object Lifecycle Management
    
    
    // Scene Setup and Content Creation
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        if (!contentCreated) {
            contentCreated = createContent()
    
            //self.scaleMode = .AspectFit
            
            backgroundColor = SKColor.blackColor()
        }
        
        
    }
    
    func createContent() -> Bool {
        
        //let invader = SKSpriteNode(imageNamed: "InvaderA_00.png")
        //invader.position = CGPoint(x: size.width/2, y: size.height/2)
        //addChild(invader)
        
        setupInvaders()
        
        setupShip()
        
        setupHud()
 
        return true
    }
    
    func makeInvaderOfType(invaderType: InvaderType) -> (SKNode) {
        
        // 1
        var color: SKColor
        
        switch(invaderType) {
        case .A:
            color = SKColor.redColor()
        case .B:
            color = SKColor.greenColor()
        case .C:
            color = SKColor.blueColor()
        }
        
        // 2
        let invader = SKSpriteNode(color: color, size: kInvaderSize)
        invader.name = kInvaderName
        
        return invader
    }
    
    func setupInvaders() {
        
        // 1
        let baseOrigin = CGPoint(x:size.width / 3, y:180)
        /*
        let baseOrigin = CGPoint(
            x: (size.width + kInvaderGridSpacing.width) / 2.0 - 3 * (kInvaderSize.width + kInvaderGridSpacing.width),
            y: 2.0/3.0 * size.height - (kInvaderSize.height + kInvaderGridSpacing.height) * 7
        )
        */

        for row in 1...kInvaderRowCount {
            
            // 2
            var invaderType: InvaderType
            switch row % 3 {
            case 0: invaderType = .A
            case 1: invaderType = .B
            case 2: invaderType = .C
            default: invaderType = .A
            }
            
            
            // 3
            let invaderPositionY = CGFloat(row) * (kInvaderSize.height * 2) + baseOrigin.y
            var invaderPosition = CGPoint(x:baseOrigin.x, y:invaderPositionY)
            
            // 4
            for _ in 1...kInvaderColCount {
                
                // 5
                let invader = makeInvaderOfType(invaderType)
                invader.position = invaderPosition
                addChild(invader)
                
                // 6
                invaderPosition = CGPoint(x: invaderPosition.x + kInvaderSize.width + kInvaderGridSpacing.width, y: invaderPositionY)
            }
        }
    }
    
    func setupShip() {
        // 1
        let ship = makeShip()
        
        // 2
        //ship.position = CGPoint(x:size.width / 2.0, y: 128.0)
        ship.position = CGPoint(x:size.width / 2.0, y:kShipSize.height / 2.0)
        //print(ship.position)
        addChild(ship)
    }
    
    func makeShip() -> SKNode {
        let ship = SKSpriteNode(color: SKColor.greenColor(), size: kShipSize)
        ship.name = kShipName
        return ship
    }
    
    func setupHud() {
        // 1
        let scoreLabel = SKLabelNode(fontNamed: "Courier")
        scoreLabel.name = kScoreHudName
        scoreLabel.fontSize = 25
        
        // 2
        scoreLabel.fontColor = SKColor.greenColor()
        scoreLabel.text = String(format: "Score: %04u", 0)
        
        // 3
        print(size.height)
        scoreLabel.position = CGPoint(x: frame.size.width / 2, y: size.height - (40 + scoreLabel.frame.size.height/2))
        addChild(scoreLabel)
        
        // 4
        let healthLabel = SKLabelNode(fontNamed: "Courier")
        healthLabel.name = kHealthHudName
        healthLabel.fontSize = 25
        
        // 5
        healthLabel.fontColor = SKColor.redColor()
        healthLabel.text = String(format: "Health: %.1f%%", 100.0)
        
        // 6
        healthLabel.position = CGPoint(x: frame.size.width / 2, y: size.height - (80 + healthLabel.frame.size.height/2))
        addChild(healthLabel)
    }
    
    override func update(currentTime: CFTimeInterval) {
        moveInvadersForUpdate(currentTime)
    }
    
    //Scene update helpers
    func moveInvadersForUpdate(currentTime: CFTimeInterval) {
        
        // 1
        if (currentTime - timeOfLastMove < timePerMove) {
            return
        }
        
        // 2
        enumerateChildNodesWithName(kInvaderName) {
            node, stop in
            
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
            
            // 3
            self.timeOfLastMove = currentTime
            
        }
        self.determineInvaderMovementDirection()
    }
    
    //Invader Movement Helpers
    func determineInvaderMovementDirection() {
        
        // 1
        var proposedMovementDirection: InvaderMovementDirection = invaderMovementDirection
        
        // 2
        enumerateChildNodesWithName(kInvaderName) { node, stop in
            switch self.invaderMovementDirection {
            case .Right:
                //3
                if (CGRectGetMaxX(node.frame) >= node.scene!.size.width - 1.0) {
                    proposedMovementDirection = .DownThenLeft
                    stop.memory = true
                }
            case .Left:
                //4
                if (CGRectGetMinX(node.frame) <= 1.0) {
                    proposedMovementDirection = .DownThenRight
                    
                    stop.memory = true
                }
            case .DownThenLeft:
                //5
                proposedMovementDirection = .Left
                stop.memory = true
            case .DownThenRight:
                //6
                proposedMovementDirection = .Right
                stop.memory = true
            default:
                break
            }
        }
        
        //7
        if (proposedMovementDirection != invaderMovementDirection) {
            invaderMovementDirection = proposedMovementDirection
        }
    }
    
    // Bullet Helpers
    
    // User Tap Helpers
    
    // HUD Helpers
    
    // Physics Contact Helpers
    
    // Game End Helpers

    
    /*
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            sprite.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(sprite)
        }
    }
   */
    
}
