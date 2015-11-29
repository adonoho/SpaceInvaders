//
//  GameOverScene.swift
//  SKInvaders
//
//  Created by Riccardo D'Antoni on 15/07/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

import UIKit
import SpriteKit

class GameOverScene: SKScene {

    weak var endSceneDelegate: EndSceneDelegate? = nil

    // Private GameScene Properties
    
    var contentCreated = false
    
    // Object Lifecycle Management
    
    // Scene Setup and Content Creation
    
    override func didMoveToView(view: SKView) {
        
        if (!contentCreated) {

            createContent()
            configureRecognizers()

            contentCreated = true
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

    var recognizers: [UIGestureRecognizer] = []

    func configureRecognizers() {

        let tapRecognizer = UITapGestureRecognizer(target: self, action: "selectTarget:")

        view?.addGestureRecognizer(tapRecognizer)

        recognizers = [tapRecognizer]
    }

    func removeRecognizers() {

        for recognizer in recognizers {

            recognizer.view?.removeGestureRecognizer(recognizer)
        }
        recognizers = []
    }

    func selectTarget(recognizer: UITapGestureRecognizer) {
        
        log.debug("")

        removeRecognizers()
        endSceneDelegate?.endScene(self)
    }
}
