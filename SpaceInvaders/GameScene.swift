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
let kInvaderSize = CGSize(width: 24, height: 16)

class GameScene: SKScene {

    let kInvaderGridSpacing = CGSize(width: 12, height: 12)
    let kInvaderRowCount = 6
    let kInvaderColCount = 6
    let kInvaderName = "invader"

    var contentCreated: Bool = false

    func createContent() -> Bool {

//        let invader = SKSpriteNode(imageNamed: "InvaderA_00.png")
//        invader.position = CGPoint(x: size.width/2, y: size.height/2)
//        addChild(invader)

        setupInvaders()
        backgroundColor = SKColor.blackColor()

        return true
    }

    func makeInvaderOfType(invaderType: InvaderType) -> SKNode {

        var color: SKColor

        switch invaderType {
        case .A:
            color = SKColor.redColor()
        case .B:
            color = SKColor.greenColor()
        case .C:
            color = SKColor.blueColor()
        }
        let invader = SKSpriteNode(color: color, size: kInvaderSize)
        invader.name = kInvaderName

        return invader
    }

    func setupInvaders() {

        let baseOrigin = CGPoint(x: size.width/3, y: 180)

        for row in 1...kInvaderRowCount {

            var invaderType: InvaderType

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
    override func didMoveToView(view: SKView) {

        if !contentCreated {

            contentCreated = createContent()
        }
//        /* Setup your scene here */
//        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
//        myLabel.text = "Hello, World!";
//        myLabel.fontSize = 65;
//        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
//        
//        self.addChild(myLabel)
    }
    
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
   
    override func update(currentTime: CFTimeInterval) {

    }
}
