//
//  GameViewController.swift
//  SpaceInvaders
//
//  Created by Andrew Donoho on 11/22/15.
//  Copyright (c) 2015 Donoho Design Group, LLC. All rights reserved.
//

import UIKit
import SpriteKit

protocol EndSceneDelegate: class {

    func endScene(scene: SKScene)
}

class GameViewController: UIViewController, EndSceneDelegate {

    var gameScene: GameScene?
    var gameOverScene: GameOverScene?

    func gameSceneWithFileNamed(fileNamed: String) -> GameScene? {

        if let scene = GameScene(fileNamed: "GameScene"), skView = view as? SKView {

            let size = CGSize(
                width:  skView.bounds.size.width  / 2 - 2 * kInsetWidth,
                height: skView.bounds.size.height / 2
            )
            scene.size = size
            scene.scaleMode = .AspectFit
            scene.endSceneDelegate = self

            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.ignoresSiblingOrder = true

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

    // MARK: - EndSceneDelegate methods.

    func endScene(scene: SKScene) {

        if gameScene == scene, let size = gameScene?.size, skView = view as? SKView {

            gameOverScene = GameOverScene(size: size)
            gameOverScene?.endSceneDelegate = self

            skView.presentScene(gameOverScene!,
                transition: SKTransition.doorsOpenHorizontalWithDuration(1.0))
        }
        else if gameOverScene == scene, let gameScene = gameScene, skView = view as? SKView {

            skView.presentScene(gameScene,
                transition: SKTransition.doorsCloseHorizontalWithDuration(1.0))
        }

    } // endScene(_:)
}
