//
//  GameViewController.swift
//  SpaceInvaders
//
//  Created by Andrew Donoho on 11/22/15.
//  Copyright (c) 2015 Donoho Design Group, LLC. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController, GameSceneDelegate {

    var gameScene: GameScene?
    var gameOverScene: GameOverScene?
    var gameRecognizers: [UIGestureRecognizer] = []

    func configureGameRecognizers() {

        let tapRecognizer = UITapGestureRecognizer(target: self, action: "selectTarget:")

        let swipeRightRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeRightTarget:")
        swipeRightRecognizer.direction = .Right

        let swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeLeftTarget:")
        swipeLeftRecognizer.direction = .Left

        view.addGestureRecognizer(tapRecognizer)
        view.addGestureRecognizer(swipeRightRecognizer)
        view.addGestureRecognizer(swipeLeftRecognizer)

        gameRecognizers = [tapRecognizer, swipeRightRecognizer, swipeLeftRecognizer]
    }

    func removeGameRecognizers() {

        for recognizer in gameRecognizers {

            recognizer.view?.removeGestureRecognizer(recognizer)
        }
        gameRecognizers = []
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

    func gameSceneWithFileNamed(fileNamed: String) -> GameScene? {

        if let scene = GameScene(fileNamed: "GameScene"), skView = view as? SKView {

            let size = CGSize(
                width:  skView.bounds.size.width  / 2 - 2 * kInsetWidth,
                height: skView.bounds.size.height / 2
            )
            scene.size = size
            scene.scaleMode = .AspectFit
            scene.gameSceneDelegate = self

            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.ignoresSiblingOrder = true

            configureGameRecognizers()

            skView.presentScene(scene)

            return scene
        }
        return nil
    }

    override func viewDidLoad() {

        super.viewDidLoad()
    }

    override func viewWillLayoutSubviews() {

        if nil == gameScene {

            gameScene = gameSceneWithFileNamed("GameScene")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - GameSceneDelegate methods.

    func selectTapToPlay(recognizer: UITapGestureRecognizer) {

        log.debug("")

        if let _ = gameOverScene, gameScene = gameScene, skView = view as? SKView {

            recognizer.view?.removeGestureRecognizer(recognizer)
            configureGameRecognizers()

            skView.presentScene(gameScene,
                transition: SKTransition.doorsCloseHorizontalWithDuration(1.0))
        }
    }
    
    func endGameScene(gameScene: GameScene) {

        removeGameRecognizers()

        if gameScene == self.gameScene, let skView = view as? SKView {

            gameOverScene = GameOverScene(size: gameScene.size)

            let tapRecognizer = UITapGestureRecognizer(target: self, action: "selectTapToPlay:")
            skView.addGestureRecognizer(tapRecognizer)

            skView.presentScene(gameOverScene!,
                transition: SKTransition.doorsOpenHorizontalWithDuration(1.0))
        }
    } // endGameScene(_:)
}
