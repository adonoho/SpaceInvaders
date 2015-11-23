//
//  GameViewController.swift
//  SpaceInvaders
//
//  Created by Andrew Donoho on 11/22/15.
//  Copyright (c) 2015 Donoho Design Group, LLC. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    var gameScene: GameScene?
    
    func configureGestureRecognizers(gameScene: GameScene) {
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "selectTarget:")
        
        let swipeRightRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeRightTarget:")
        swipeRightRecognizer.direction = .Right
        
        let swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeLeftTarget:")
        swipeLeftRecognizer.direction = .Left
        
        view.addGestureRecognizer(tapRecognizer)
        view.addGestureRecognizer(swipeRightRecognizer)
        view.addGestureRecognizer(swipeLeftRecognizer)
        
    }
    
    func selectTarget(recognizer: UITapGestureRecognizer) {
        print("select")
        //log.debug("select")
        
        let skView = self.view as! SKView
        
        if skView.scene == gameScene {
            gameScene?.fireMissle()
        } else {
            if let gameOverScene = skView.scene as? GameOverScene {
                gameOverScene.loadGameScene()
                
                if let scene = GameScene(fileNamed: "GameScene") {
                    // Configure the view.
                    let skView = self.view as! SKView
                    skView.showsFPS = true
                    skView.showsNodeCount = true
                    
                    /* Sprite Kit applies additional optimizations to improve rendering performance */
                    skView.ignoresSiblingOrder = true
                    
                    /* Set the scale mode to scale to fit the window */
                    scene.scaleMode = .ResizeFill
                    
                    skView.presentScene(scene)
                    
                    gameScene = scene
                    
                    configureGestureRecognizers(scene)
                }
                
            }
        }
    
    }
    
    func swipeRightTarget(recognizer: UISwipeGestureRecognizer) {
        print("swipe right")
        gameScene?.moveRight()
        //log.debug("swipe right")
    }
    
    func swipeLeftTarget(recognizer: UISwipeGestureRecognizer) {
        print("swipe left")
        gameScene?.moveLeft()
        
        //log.debug("swipe left")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let scene = GameScene(fileNamed: "GameScene") {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .ResizeFill
            
            skView.presentScene(scene)
            
            gameScene = scene
            
            configureGestureRecognizers(scene)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
}
