//
//  GameOverScene.swift
//  SpaceInvaders
//
//  Created by Robert Murray on 11/22/15.
//  Copyright © 2015 Donoho Design Group, LLC. All rights reserved.
//

import UIKit
import SpriteKit

class GameOverScene: SKScene {
    
    // Private GameScene Properties
    
    var contentCreated = false
    
    // Object Lifecycle Management
    
    // Scene Setup and Content Creation
    
    override func didMoveToView(view: SKView) {
        
        if (!self.contentCreated) {
            self.createContent()
            self.contentCreated = true
        }
        
    }
    
    func createContent() {
        
        let gameOverLabel = SKLabelNode(fontNamed: "Courier")
        gameOverLabel.fontSize = 50
        gameOverLabel.fontColor = SKColor.whiteColor()
        gameOverLabel.text = "Game Over!"
        gameOverLabel.position = CGPointMake(self.size.width/2, 2.0 / 3.0 * self.size.height);
        
        self.addChild(gameOverLabel)
        
        let tapLabel = SKLabelNode(fontNamed: "Courier")
        tapLabel.fontSize = 25
        tapLabel.fontColor = SKColor.whiteColor()
        tapLabel.text = "(Tap to Play Again)"
        tapLabel.position = CGPointMake(self.size.width/2, gameOverLabel.frame.origin.y - gameOverLabel.frame.size.height - 40);
        
        self.addChild(tapLabel)
        
        // black space color
        self.backgroundColor = SKColor.blackColor()
        
    }
    
   func loadGameScene() {
        let gameScene = GameScene(size: self.size)
        gameScene.scaleMode = .AspectFill
        
        self.view!.presentScene(gameScene, transition: SKTransition.doorsCloseHorizontalWithDuration(1.0))
        
    }
}
