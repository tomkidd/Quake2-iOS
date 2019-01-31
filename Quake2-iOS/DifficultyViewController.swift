//
//  DifficultyViewController.swift
//  Quake2-iOS
//
//  Created by Tom Kidd on 1/30/19.
//

import UIKit

class DifficultyViewController: UIViewController {
    
    var difficulty = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func easyDifficulty(_ sender: UIButton) {
        difficulty = 0
        performSegue(withIdentifier: "StartGameSegue", sender: self)
    }
    
    @IBAction func normalDifficulty(_ sender: UIButton) {
        difficulty = 1
        performSegue(withIdentifier: "StartGameSegue", sender: self)
    }
    
    @IBAction func hardDifficulty(_ sender: UIButton) {
        difficulty = 2
        performSegue(withIdentifier: "StartGameSegue", sender: self)
    }
    
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (segue.destination as! GameViewController).difficulty = difficulty
        (segue.destination as! GameViewController).newgame = true
    }

}
