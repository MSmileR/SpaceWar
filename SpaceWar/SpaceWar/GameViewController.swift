//
//  GameViewController.swift
//  SpaceWar
//
//  Created by Martin on 30.06.2020.
//  Copyright © 2020 Martin. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    //MARK: - Variable
    var gameScene : GameScene!
    var pauseVC : PauseViewController!
    var gameOverVC  : GameOverViewController!
    //MARK: - Function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pauseVC = (storyboard?.instantiateViewController(withIdentifier: "PauseViewController") as! PauseViewController)
        gameOverVC = (storyboard?.instantiateViewController(withIdentifier: "GameOverViewController") as! GameOverViewController)
        
        pauseVC.delegate = self
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                gameScene = (scene as! GameScene)
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: - Action
    
    func showPauseScreen (_ viewController: UIViewController){
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.view.frame = view.bounds
        
        viewController.view.alpha = 0
        
        UIView.animate(withDuration: 0.5) {
            viewController.view.alpha = 1
        }
    }
    
    @IBAction func pauseButton(_ sender: UIButton) {
        gameScene.pauseTheGame()
        showPauseScreen(pauseVC)
    }
    
    func hidePauseScreen(_ viewController: UIViewController){
        viewController.willMove(toParent: nil)
        viewController.removeFromParent()
        
        viewController.view.alpha = 1
        
        UIView.animate(withDuration: 0.5, animations: {
            viewController.view.alpha = 0
        }) { (compled) in
            viewController.view.removeFromSuperview()
        }
    }
}

extension GameViewController : PauseVCDelegate {
    func pauseVCSoundButton(_ viewController: PauseViewController) {
        print("soundButton")
    }
    
    func pauseVCMusicButton(_ viewController: PauseViewController) {
        gameScene.musicOn = !gameScene.musicOn
        gameScene.musicOnOff()
        
        let image = gameScene.musicOn ? UIImage(named: "switch-on") : UIImage(named: "switch-off")
        viewController.musicButton.setImage(image, for: .normal)
    }
    
    func pauseVCPlayButton(_ viewController: PauseViewController) {
        hidePauseScreen(pauseVC)
        gameScene.unpauseTheGame()
    }
    
    
}
