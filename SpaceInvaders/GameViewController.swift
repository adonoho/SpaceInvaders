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

    func configureGestureRecognizers() {

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

        log.debug("")

        gameScene?.fireMissle()
    }
    
    func swipeRightTarget(recognizer: UISwipeGestureRecognizer) {

        log.debug("")

        gameScene?.moveRight()
    }

    func swipeLeftTarget(recognizer: UISwipeGestureRecognizer) {

        log.debug("")

        gameScene?.moveLeft()
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
            configureGestureRecognizers()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
}
