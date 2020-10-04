//
//  PauseViewController.swift
//  SpaceWar
//
//  Created by Martin on 30.09.2020.
//  Copyright © 2020 Martin. All rights reserved.
//

import UIKit

protocol PauseVCDelegate {
    func pauseVCPlayButton (_ viewController: PauseViewController)
    func pauseVCSoundButton (_ viewController: PauseViewController)
    func pauseVCMusicButton (_ viewController: PauseViewController)
}

class PauseViewController: UIViewController {
    
    var delegate : PauseVCDelegate!
    
    @IBOutlet weak var soundButton: UIButton!
    @IBOutlet weak var musicButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    
    
    @IBAction func soundButtonPress(_ sender: Any) {
        delegate.pauseVCSoundButton(self)
    }
    
    @IBAction func musicButoonPress(_ sender: Any) {
        delegate.pauseVCMusicButton(self)
    }
    @IBAction func shopButtonPress(_ sender: Any) {
    }
    
    @IBAction func playButtonPress(_ sender: UIButton) {
        delegate.pauseVCPlayButton(self)
    }
    
    @IBAction func menuButtonPress(_ sender: UIButton) {
    }
}
