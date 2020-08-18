//
//  CustomNavigationController.swift
//  WebloomSolutionsSysTest
//
//  Created by Varender Singh on 18/08/20.
//  Copyright © 2020 Varender. All rights reserved.
//

import UIKit

class CustomNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        AudioPlayer.shared.delegate = self
        // Do any additional setup after loading the view.
    }

}


extension CustomNavigationController: AudioPlayerDelegateToCustomNC {
  
    func clickedOnImageOfPlayingSong() {
        guard let vc = self.storyboard?.instantiateViewController(identifier: "PlayerViewController") as? PlayerViewController else { return }
        self.present(vc, animated: true, completion: nil)
    }
    
}
